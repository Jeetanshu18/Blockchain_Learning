// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

library AddressUtils {
    function isContract(address _addr) internal view returns(bool addressCheck) {
        uint size;
        assembly { size := extcodesize(_addr) }
        addressCheck = size > 0;
    }
}

interface ERC721 {
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
}

interface ERC721TokenReceiver {
   function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);
}

contract ERC721Token is ERC721 {
    using AddressUtils for address;

    mapping(address => uint) private ownerToTokenCount;
    mapping(uint => address) private idToOwner;
    mapping(uint => address) private idToApproved;
    mapping(address => mapping(address => bool)) private ownerToOperators;
    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;
    string public name;
    string public symbol;
    string public tokenURIBase;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _tokenURIBase
    ) public {
        name = _name;
        symbol = _symbol;
        tokenURIBase = _tokenURIBase;
    }

    function tokenURI(uint _tokenId) external view returns(string memory) {
        return string(abi.encodePacked(tokenURIBase, '/', _tokenId));
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return ownerToTokenCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        return idToOwner[_tokenId];
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable {
        _safeTransferFrom(_from, _to, _tokenId, data);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        _transfer(_from, _to, _tokenId);
    }

    function _safeTransferFrom(address _from, address _to, uint _tokenId, bytes memory data) internal {
        _transfer(_from, _to, _tokenId);

        if(_to.isContract()) {
           bytes4 retVal = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data);            
           require(retVal == MAGIC_ON_ERC721_RECEIVED);
        }
    }

    function _transfer(address _from, address _to, uint _tokenId) 
        internal
        canTransfer(_tokenId) {
        ownerToTokenCount[_from] -= 1;
        ownerToTokenCount[_to] += 1;
        idToOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external payable {
        address owner = idToOwner[_tokenId];
        require(msg.sender == owner);
        idToApproved[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        ownerToOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) external view returns (address) {
        return idToApproved[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        ownerToOperators[_owner][_operator];
    }

    function _mint(uint _tokenId, address owner) internal {
        require(idToOwner[_tokenId] == address(0));
        idToOwner[_tokenId] = owner;
        ownerToTokenCount[owner] += 1;
        emit Transfer(address(0), owner, _tokenId);
    }

    modifier canTransfer(uint _tokenId) {
        address owner = idToOwner[_tokenId];
        require(owner == msg.sender 
            || idToApproved[_tokenId] == msg.sender
            || ownerToOperators[owner][msg.sender] == true);
        _;
    }
}
