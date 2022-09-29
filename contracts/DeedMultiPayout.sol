 // SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

contract Deed {
    address public lawyer;
    address payable public beneficiary;
    uint public earliest;
    uint public amount;
    uint constant public PAYOUT = 10;
    uint constant public INTERVAL = 10; //10sec 
    uint public paidPayouts;

    constructor(
        address _lawyer,
        address payable _beneficiary,
        uint fromNow
    ) payable public {
        lawyer = _lawyer;
        beneficiary = _beneficiary;
        earliest = block.timestamp + fromNow;
        amount = msg.value / PAYOUT;
    }

    function withDraw() public {
        require(msg.sender == beneficiary, 'Beneficiary Only');
        require(block.timestamp >= earliest);
        require(paidPayouts < PAYOUT);

        uint eligiblePayouts = (block.timestamp - earliest) / INTERVAL;
        uint duePayouts = eligiblePayouts - paidPayouts;
        duePayouts = duePayouts + paidPayouts > PAYOUT ? PAYOUT - paidPayouts : duePayouts;
        paidPayouts += duePayouts;

        beneficiary.transfer(deuePayouts * amount);
    }
}
