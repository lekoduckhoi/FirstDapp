pragma solidity ^0.8.3;

import "./LEKO.sol";

contract NFT {
    LEKOToken leko;
    address admin;
    uint tokenId = 0;
    
    constructor() {
        admin = msg.sender;
    }
    // owner of tokenId
    mapping (uint => address) ownerOfTokenId;
    function viewOwnerOfTokenId(uint _tokenId) public view returns(address) {
        return ownerOfTokenId[_tokenId];
    }
    
    
    // balance of user 
    mapping (address => uint) balanceOf;
    function viewBalanceOfOwner(address _owner) public view returns(uint) {
        return balanceOf[_owner];
    }
    
    // total Supply
    uint totalSupply;
    function viewTotalSupply() public view returns(uint) {
        return totalSupply;
    }
    
    
    // allowance for TransferFrom funciton   check if A allow B for spend token C is ?bool
    mapping (address => mapping(address => mapping(uint => bool))) allowance;
    
    // all events
    event Mint(address indexed creator, uint tokenId,  string _name, string _symbol, string _imgURL);
    event Transfer(address indexed __from, address __to, uint __tokenId);
    event Approval(address indexed owner, address indexed spender, uint _tokenId);
    event Sell(address indexed seller, uint _tokenId, uint amount);
    event Buy(address indexed buyer, address seller, uint _tokenId, uint amount);
    
    //data for a token      string name  string symbol  string imgURL
    mapping (uint => string[]) dataOfToken;
    function viewDataOfTokenId(uint _id) public view returns(string[] memory) {
        return dataOfToken[_id];
    }
    
    // setLeko contract
    function setLEKOcontract(address _address) public {
        require(msg.sender == admin);
        leko = LEKOToken(_address);
    }
    
    // function MINT require 5000 LEKO
    function mint(string memory _name, string memory _symbol, string memory _imgURL) public {
        require(leko.transferFrom(msg.sender, address(this), 5000*10**18), "cant take leko"); 
        tokenId++;
        ownerOfTokenId[tokenId] = msg.sender;
        balanceOf[msg.sender]++;
        totalSupply++;
        dataOfToken[tokenId] = [_name, _symbol, _imgURL];
        emit Mint(msg.sender, tokenId, _name, _symbol, _imgURL);
    }
    
    // function Transfer
    function transfer(address _to, uint _tokenId) public {
        require(ownerOfTokenId[_tokenId] == msg.sender, "You are not the owner");
        ownerOfTokenId[_tokenId] = _to;
        balanceOf[msg.sender] -= 1;
        balanceOf[_to] +=1;
    }
    
    // function Approve
    function approve(address _to, uint _tokenId) public {
        require(ownerOfTokenId[_tokenId] == msg.sender, "You r not the owner");
        allowance[msg.sender][_to][_tokenId] = true;
        emit Approval(msg.sender, _to, _tokenId);
    }
    
    // function TransferFrom
    function transferFrom(address _from, address _to, uint _tokenId) public {
        require(allowance[_from][msg.sender][_tokenId] == true, "You dont have permission");
        allowance[_from][msg.sender][_tokenId] = false;
        ownerOfTokenId[_tokenId] = _to;
        balanceOf[_from] -= 1;
        balanceOf[_to] +=1;
    }
    
    // Buy and Sell NFT
    mapping (uint => uint) priceOfTokenId;
    mapping (uint => bool) forSale;
    function viewPrice(uint _tokenId) public view returns(uint) {
        return priceOfTokenId[_tokenId];
    }
    function viewConditionForSale(uint _tokenId) public view returns(bool) {
        return forSale[_tokenId];
    }
    
    // function sell 
    function sell(uint _tokenId, uint amount) public {
        require(forSale[_tokenId] == false, "already forSale");
        require(ownerOfTokenId[_tokenId] == msg.sender, "You dont have permission");
        priceOfTokenId[_tokenId] = amount;
        forSale[_tokenId] = true;
        emit Sell(msg.sender, _tokenId, amount);
    }
        
    //function buy
    function buy(uint _tokenId) public {
        require(forSale[_tokenId] == true, "token not for sale");
        forSale[_tokenId] = false;
        address prevOwner = ownerOfTokenId[_tokenId];
        uint prevPrice = priceOfTokenId[_tokenId];
        require(leko.transferFrom(msg.sender, prevOwner, prevPrice*10**18), "cant take leko"); 
        ownerOfTokenId[_tokenId] = msg.sender;
        balanceOf[msg.sender] += 1;
        balanceOf[prevOwner] -=1;
        emit Buy(msg.sender, prevOwner, _tokenId, prevPrice);
    }


// remember adding Leko methods later

// 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2

}