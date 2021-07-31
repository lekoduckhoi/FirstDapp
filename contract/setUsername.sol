pragma solidity ^0.8.3;

import "./LEKO.sol";

contract setUsername {
    
    address admin;
    LEKOToken leko;
    
    constructor() {
        admin = (msg.sender);
    }
    
    mapping (address => string) usernameOf;
    
    string[] usernames;
    
    event Set(address indexed _address, string _username);
    
    function setLEKOcontract(address _address) public {
        require(msg.sender == admin);
        leko = LEKOToken(_address);
    }
    function withdraw() public {
        require(msg.sender == admin);
        uint _amount = leko.balanceOf(address(this));
        leko.transfer(admin, _amount);
    }
    function set(string memory _username) public {
        require(leko.balanceOf(tx.origin) >= 5000*10**18);
        leko.transferFrom(msg.sender, address(this), 5000*10**18);
        usernameOf[msg.sender] = _username;
        usernames.push(_username);
        emit Set(msg.sender, _username);
    }
    function viewUsername(address _address) public view returns(string memory) {
        return usernameOf[_address];
    }
    function viewUsernameList() public view returns(string[] memory) {
        return usernames;
    }
}
