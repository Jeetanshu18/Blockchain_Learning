 // SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

contract SplitPayment {

    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function send(address payable[] memory to, uint[] memory amount) payable onlyOwner public {
        require(to.length == amount.length);
        for(uint i = 0; i < to.length; i++) {
            to[i].transfer(amount[i]);
        } 
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'Only owner can the send the amount');
        _;
    }
