// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

contract Lottery1 {
    enum State {
        IDLE,
        BETTING
    }
    State public currentState = State.IDLE;
    address payable[] public players;
    uint public betCount;
    uint public betSize;
    uint public houseFee;
    address public admin;

    constructor(uint fee) public {
        require(fee > 1 && fee < 99);
        houseFee = fee;
        admin = msg.sender;
    }

    function createBet(uint count, uint size) external payable inState(State.IDLE) onlyAdmin() {
        betCount = count;
        betSize = size;
        currentState = State.BETTING;
    }

    function bet() external payable inState(State.BETTING) {
        require(msg.value == betSize);
        players.push(payable(msg.sender));
        if(players.length == betCount) {
            uint winner = _randomModulo(betCount);
            players[winner].transfer((betSize * betCount) * (100 - houseFee) / 100);
            currentState = State.IDLE;
            delete players;
        }
    }

    function cancel() external payable inState(State.BETTING) onlyAdmin() {
        for(uint i = 0; i < players.length; i++) {
            players[i].transfer(betSize);
        }
        delete players;
        currentState = State.IDLE;
    }

    function _randomModulo(uint modulo) view internal returns(uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % modulo;
    }

    modifier inState(State state) {
        require(state == currentState);
        _;
    }

    modifier onlyAdmin() {
        require(admin == msg.sender);
        _;
    }
}
