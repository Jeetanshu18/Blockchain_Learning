// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

contract EventOrganization {
    struct Event {
        address admin;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemaining;
    }
    mapping(uint => Event) public events;
    mapping(address => mapping(uint => uint)) public tickets;
    uint public nextId;

    function createEvent(
        string calldata name,
        uint date,
        uint price,
        uint ticketCount
    ) external {
        require(date >= block.timestamp);
        require(ticketCount > 0);

        events[nextId] = Event(
            msg.sender,
            name,
            date,
            price,
            ticketCount,
            ticketCount
        );

        nextId++;
    }

    function buyTicket(uint id, uint quantity) payable external eventExist(id) eventActive(id) {
        Event storage _event = events[id];

        require(msg.value == (quantity * _event.price));
        require(_event.ticketRemaining > quantity);

        _event.ticketRemaining -= quantity;
        tickets[msg.sender][id] += quantity;
    }

    function transferTicket(uint id, uint quantity, address to) external eventExist(id) eventActive(id) {
        require(tickets[msg.sender][id] > quantity);

        tickets[msg.sender][id] -= quantity;
        tickets[to][id] += quantity;
    }

    modifier eventExist(uint id) {
        require(events[id].date != 0);
        _;
    }

    modifier eventActive(uint id) {
        require(events[id].date >= block.timestamp);
        _;
    }
}
