// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

contract Loan {
    enum State {
        PENDING,
        ACTIVE,
        CLOSED
    }
    State public state = State.PENDING;
    uint public amount;
    uint public interest;
    uint public end;
    address payable public borrower;
    address payable public lender;

    constructor(
        uint _amount,
        uint _interest,
        uint _duration,
        address payable _borrower,
        address payable _lender
    ) public {
        amount = _amount;
        interest = _interest;
        end = block.timestamp + _duration;
        borrower = _borrower;
        lender = _lender;
    }

    function fund() payable external {
        require(msg.sender == lender);
        require(address(this).balance == amount);
        _transitionTo(State.ACTIVE);
        borrower.transfer(amount);
    }

    function reimburse() payable external {
        require(msg.sender == borrower);
        require(msg.value == amount + interest);
        _transitionTo(State.CLOSED);
        lender.transfer(amount + interest);
    }
 
    function _transitionTo(State to) internal {
        require(to != State.PENDING);
        require(to != state);

        if(to == State.ACTIVE) {
            require(state == State.PENDING);
            state = State.ACTIVE;
        }

        if(to == State.CLOSED) {
            require(state == State.ACTIVE);
            require(end < block.timestamp);
            state = State.CLOSED;
        }
    }
}
