 // SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

contract EtherWallet {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function deposit() payable public {}

    function send(address payable to, uint amount) public {
        require(msg.sender == owner, 'Sender is not allowed to send Ether');
        to.transfer(amount);
    }

    function balanceOf() view public returns(uint) {
        return address(this).balance;
    }
}:wq
