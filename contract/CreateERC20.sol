pragma solidity ^0.8.3;

import './LEKO.sol';

contract createERC20Token {
    address admin; 
    LEKOToken leko;
    mapping(address => address[]) UserToken;
    event Create(address indexed creator, address _token);
    constructor() {
        admin = msg.sender;
    }
    function setLEKOcontract(address _address) public {
        require(msg.sender == admin);
        leko = LEKOToken(_address);
    }
    function createERC20(uint _totalSupply, string memory _name, string memory _symbol) public {
        require(leko.transferFrom(msg.sender, address(this), 80000*10**18), "cant take leko");
        ERC20Token token = new ERC20Token(_totalSupply, _name, _symbol);
        UserToken[msg.sender].push(address(token));
        emit Create(msg.sender, address(token));
    }
    function viewAllToken(address _address) public view returns(address[] memory) {
        return UserToken[_address];
    }
    function viewLastTokenAddress(address _address) public view returns(address) {
        uint _length = UserToken[_address].length;
        if (_length == 0){
            return address(0);
        } else {
            return UserToken[_address][_length -1];
        }
    }
    function viewLastTokenTotalSupply(address _address) public view returns(uint) {
        address _lastTokenAddress = viewLastTokenAddress(_address);
        if (_lastTokenAddress == address(0)){
            return 0;
        } else {
            ERC20Token erc20 = ERC20Token(_lastTokenAddress);
            return erc20.TotalSupply();
        }
    }
    function viewLastTokenName(address _address) public view returns(string memory) {
        address _lastTokenAddress = viewLastTokenAddress(_address);
        if (_lastTokenAddress == address(0)){
            return "";
        } else {
            ERC20Token erc20 = ERC20Token(_lastTokenAddress);
            return erc20.getName();
        }
    }
    function viewLastTokenSymbol(address _address) public view returns(string memory) {
        address _lastTokenAddress = viewLastTokenAddress(_address);
        if (_lastTokenAddress == address(0)){
            return "";
        } else {
            ERC20Token erc20 = ERC20Token(_lastTokenAddress);
            return erc20.getSymbol();
        }
    }
}
contract ERC20Token {
    uint public totalSupply;
    string public name;
    string public symbol;
    uint public decimals = 18;
    mapping (address => uint) public balances;
    mapping (address => mapping(address => uint)) public allowance;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor(uint _totalSupply, string memory _name, string memory _symbol) {
        totalSupply = _totalSupply *10 ** 18;
        name = _name;
        symbol = _symbol;
        balances[tx.origin] = totalSupply;
    }
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    } 
    function TotalSupply() public view returns(uint) {
        return totalSupply;
    }
    function getName() public view returns(string memory) {
        return name;
    }
    function getSymbol() public view returns(string memory) {
        return symbol;
    }
    function transfer(address to, uint value) public returns(bool) {
        require(balances[msg.sender] >= value, 'Not Enough Balance');
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to , value);
        return true; 
    }
    function approve(address spender, uint value) public returns(bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balances[from] >= value, 'not enough balance');
        require(allowance[from][msg.sender] >= value, 'not enough allowance balance');
        allowance[from][msg.sender] -= value;
        balances[from] -= value;
        balances[to] += value;
        emit Transfer(from, to , value);
        return true;
    }
}