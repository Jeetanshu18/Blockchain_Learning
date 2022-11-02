// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ERC20Interface {
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
}

contract TokenB is ERC20, Ownable {
    ERC20Interface tokenA;
    uint public interest;
    uint public stakingDuration;

    struct StakeInfo {
        uint256 endTS;      
        uint256 amount;
        uint256 claimed;
    }

    mapping(address => bool) addressStake;
    mapping(address => StakeInfo) stakeAddress;

    constructor(ERC20Interface _tokenA) ERC20("TokenB", "TKB") {
        require(address(_tokenA) != address(0),"Token Address cannot be address 0");  
        tokenA = _tokenA;
    }

    function startStaking(uint _interest, uint _stakingDuration) public onlyOwner {
        interest = _interest;
        stakingDuration = _stakingDuration;
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function stake(uint _amount) external stakeCheck(_amount, msg.sender) {
        tokenA.transferFrom(msg.sender, address(this), _amount);
        addressStake[msg.sender] = true;

        stakeAddress[msg.sender] = StakeInfo({
            endTS: block.timestamp + stakingDuration,
            amount: _amount,
            claimed: 0
        });
    }

    function claim() external claimCheck(msg.sender) {
        uint amountEarned = stakeAddress[msg.sender].amount * interest / 100;
        mint(msg.sender, amountEarned);
        tokenA.transfer(msg.sender, stakeAddress[msg.sender].amount);
        stakeAddress[msg.sender].claimed = amountEarned;
    }

    modifier stakeCheck(uint _amount, address _address) {
        require(_amount > 0);
        require(addressStake[_address] == false);
        require(tokenA.balanceOf(_address) >= _amount);
        require(interest > 0);
        require(stakingDuration > 0);
        _;
    }

    modifier claimCheck(address _address) {
        require(addressStake[_address] == true);
        require(stakeAddress[_address].endTS > block.timestamp);
        require(stakeAddress[_address].amount != 0);
        _;
    }
}