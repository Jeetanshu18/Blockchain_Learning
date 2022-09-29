// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

contract Voting {
    mapping(address => bool) public voters;
    struct Choice {
        uint id;
        string name;
        uint votes;
    }
    struct Ballot {
        uint id;
        string name;
        Choice[] choices;
        uint end;
    }
    mapping(uint => Ballot) ballots;
    uint nextBallotId;
    address public admin;
    mapping(address => mapping(uint => bool)) votes;

    constructor() public {
        admin = msg.sender;
    }

    function addVoters(address[] calldata _voters) external {
        for(uint i = 0; i < _voters.length; i++) {
            voters[_voters[i]] = true;
        }
    }

    function createBallot(
        string memory name,
        string[] memory choices,
        uint offset
    ) public onlyAdmin() {
        ballots[nextBallotId].id = nextBallotId;
        ballots[nextBallotId].name = name;
        ballots[nextBallotId].end = block.timestamp + offset;
        for(uint i = 0; i < choices.length; i++) {
            ballots[nextBallotId].choices.push(Choice(i, choices[i], 0));
        }
    }

    function vote(uint ballotId, uint choiceId) external {
        require(voters[msg.sender] == true);
        require(votes[msg.sender][ballotId] == false);
        require(block.timestamp < ballots[ballotId].end);
        votes[msg.sender][ballotId] = true;
        ballots[ballotId].choices[choiceId].votes++;
    }

    function results(uint ballotId) view external returns(Choice[] memory) {
        require(block.timestamp > ballots[ballotId].end);
        return ballots[ballotId].choices;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }
}
