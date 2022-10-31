// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "./ERC721.sol";

contract Cryptokitty is ERC721Token {
    struct Kitty {
        uint id;
        uint generation;
        uint geneA;
        uint geneB;
    }
    mapping(uint => Kitty) private kitties;
    uint public nextId;

    address public admin;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _tokenURIBase
    ) ERC721Token(_name, symbol, _tokenURIBase) public {
        admin = msg.sender;
    }

    function breed(uint kitty1Id, uint kitty2Id) external {
        require(kitty1Id < nextId && kitty2Id < nextId);
        Kitty storage kitty1 = kitties[kitty1Id];
        Kitty storage kitty2 = kitties[kitty2Id];
        require(ownerOf(kitty1Id) == msg.sender && ownerOf(kitty2Id) == msg.sender);
        uint maxGen = kitty1.generation > kitty2.generation ? kitty1.generation : kitty2.generation;
        uint geneA = _random(4) > 1 ? kitty1.geneA : kitty2.geneA;
        uint geneB = _random(4) > 1 ? kitty1.geneB : kitty2.geneB;
        kitties[nextId] = Kitty(nextId, maxGen, geneA, geneB);
        nextId++;
    }

    function mint() external {
        require(msg.sender == admin);
        kitties[nextId] = Kitty(nextId, 1, _random(10), _random(10));
        _mint(nextId, msg.sender);
        nextId++;
    }

    function _random(uint max) internal view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % max;
    }
}