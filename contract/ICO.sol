pragma solidity ^0.8.3;

import "./LEKO.sol";

contract icoLEKO {
    address payable admin;
    LEKOToken leko;
    event Sell(address indexed buyer, uint amount);
    uint tokenSale;
    constructor() {
        admin = payable(msg.sender);
    }
    function viewTokenSale() public view returns(uint) {
        return tokenSale;
    }
    function setLEKOcontract(address _address) public {
        require(msg.sender == admin);
        leko = LEKOToken(_address);
    }
    
    function buyLeko(uint amountLEKO) payable public {
        require(msg.value == amountLEKO*10**14, "send more ETH");
        leko.transfer(msg.sender, amountLEKO*10**18);
        tokenSale += amountLEKO;
        emit Sell(msg.sender, amountLEKO);
    }
    function withdraw() public {
        require(msg.sender == admin);
        admin.transfer(address(this).balance);
    }
}