// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

contract Escrow {
    address public buyer;
    address payable public seller;
    address public lawyer;
    uint public amount;

    contract(
        address _buyer,
        address payable _seller,
        uint _amount
    ) {
        buyer = _buyer;
        seller = _seller;
        lawyer = msg.sender;
        amount = _amount;
    }

    function deposit() payable public {
        require(msg.sender == buyer);
        require(address(this).balance <= amount);
    }

    function release() public {
        require(address(this).balance == amount);
        require(msg.sender == lawyer);
        seller.transfer(amount);
    }

    functi on balanceOf() view public returns(uint) {
        return address(this).balance;
    }
}
