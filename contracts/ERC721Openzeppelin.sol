// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    IERC20 public tokenAddress;
    uint public rate = 100 * 10 ** 18;

    struct userTransaction {
        uint transactionTime;
        uint count;
    }
    mapping(address => userTransaction) ownerToTransactions;
    mapping(address => bool) isWhitelist;

    Counters.Counter private _tokenIdCounter;

    constructor(address _tokenAddress) ERC721("MyNFT", "NFT") {
        tokenAddress = IERC20(_tokenAddress);
    }

    function mintThroughToken() public verifyUser(msg.sender) {
        tokenAddress.transferFrom(msg.sender, address(this), rate);
        _mintNFT(msg.sender);
    }


    function mintThroughETH() public payable verifyUser(msg.sender) {
        require(msg.value > 1 * 10 ** 18);

        uint amountLeft = msg.value % 1 * 10 ** 18;

        for(uint i = 1; i <= amountLeft; i = i + 1 * 10 ** 18) {
            _mintNFT(msg.sender);
        }

        (bool sent, bytes memory data) = msg.sender.call{value: amountLeft}("");
    }

    receive() external payable {
    }

    fallback() external payable {
    }


    function _mintNFT(address _address) internal {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_address, tokenId);

        if(ownerToTransactions[_address].count == 0) {
            ownerToTransactions[_address].transactionTime = block.timestamp;
        }
        else if(ownerToTransactions[_address].count < 5) {
            ownerToTransactions[_address].count += 1;
        }
        else if(ownerToTransactions[_address].count == 5) {
            ownerToTransactions[_address].transactionTime = block.timestamp;
            ownerToTransactions[_address].count = 0;
        }
    }


    function approve(uint _amount) public {
        tokenAddress.approve(address(this), _amount);
    }

    function mintNFTs(uint amount) public {
        uint leftAmount = amount % 100;
    }

    function whitelist(address _address, bool _isWhitelisted) public onlyOwner{
        isWhitelist[_address] = _isWhitelisted;
    }

    function withdrawToken() public onlyOwner {
        tokenAddress.transfer(msg.sender, tokenAddress.balanceOf(address(this)));
    }

    modifier verifyUser(address _address) {
        require(isWhitelist[_address] == true);
        require(ownerToTransactions[msg.sender].count < 5 ||
            block.timestamp - ownerToTransactions[msg.sender].transactionTime > 10 minutes );
        _;
    }
}
