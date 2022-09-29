// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

contract AdvancedSotrage {
    uint[] public ids;

    function addElement(uint element) public {
        ids.push(element);
    }

    function getElement(uint index) view public returns(uint) {
        return ids[index];
    }

    function getIds() view public returns(uint[] memory) {
        return ids;
    }

    function getIdsLength() view public returns(uint) {
        return ids.length; 
    }
}
