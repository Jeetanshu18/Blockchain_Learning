 // SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

contract Deed {
    address public lawyer;
    address payable public beneficiary;
    uint public earliest;

    constructor(
        address _lawyer,
        address payable _beneficiary,
        uint fromNow
    ) payable public {
        lawyer = _lawyer;
        beneficiary = _beneficiary;
        earliest = block.timestamp + fromNow;
    }

    function withDraw() public {
        require(msg.sender == lawyer, 'Lawyer Only');
        require(block.timestamp >= earliest);
        beneficiary.transfer(address(this).balance);
    }
}
