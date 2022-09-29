// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

contract DAO {
    struct Proposal {
        uint id;
        string name;
        uint amount;
        address payable recipient;
        uint votes;
        uint end;
        bool executed;
    }
    mapping(address => bool) public investors;
    mapping(address => uint) public shares;
    mapping(uint => Proposal) public proposals;
    mapping(address => mapping(uint => bool)) public votes;
    uint public totalShares;
    uint public totalAmount;
    uint public contributionTime;
    uint public nextProposalId;
    uint public voteTime;
    uint public quorum;
    address public admin;

    constructor(uint duration) {
        contributionTime = block.timestamp + duration;
    }

    function contribute() payable external {
        require(contributionTime >= block.timestamp);
        investors[msg.sender] = true;
        shares[msg.sender] += msg.value;
        totalShares += msg.value;
        totalAmount += msg.value;
    }

    function redeemShare(uint _shares) payable external {
        require(shares[msg.sender] >= _shares);
        require(totalAmount >= _shares);

        shares[msg.sender] -= _shares;
        // totalShares += _shares;
        totalAmount -= _shares;

        payable(msg.sender).transfer(_shares);
    }

    function transferShare(uint _shares, address to) external {
        require(shares[msg.sender] >= _shares);
        shares[msg.sender] -= _shares;
        shares[to] += _shares;
        investors[to] = true; 
    }

    function createProposal(string memory name, uint amount, address payable recipient) external onlyInvestors{
        require(amount < totalAmount);
        proposals[nextProposalId] = Proposal(
            nextProposalId,
            name,
            amount,
            recipient,
            0,
            block.timestamp + voteTime,
            false
        );

        totalAmount -= amount;
        nextProposalId++;
    }

    function vote(uint proposalId) external payable onlyInvestors {
        // Proposal storage proposal = proposal[proposalId];

        require(votes[msg.sender][proposalId] == false);
        require(block.timestamp < proposals[proposalId].end);

        votes[msg.sender][proposalId] = true;
        proposals[proposalId].votes += shares[msg.sender];
    }

    function executeProposal(uint proposalId) external onlyAdmin{
        Proposal storage proposal = proposals[proposalId];

        require(block.timestamp < proposal.end);
        require(proposal.executed == false);
        require((proposal.votes / totalShares) * 100 >= quorum);

        _transferEther(proposal.amount, proposal.recipient);
    }

    function withDrawEther(uint amount, address payable to) external onlyAdmin{
        _transferEther(amount, to);
    }

    fallback() payable external {
        totalAmount += msg.value;
    }

    function _transferEther(uint amount, address payable to) internal {
        require(totalAmount > amount);
        totalAmount -= amount;
        to.transfer(amount);
    }

    modifier onlyInvestors() {
        require(investors[msg.sender] == true);
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }
}
