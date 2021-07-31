pragma solidity ^0.8.3;

import "./LEKO.sol";

contract Farming {
    address admin;
    LEKOToken leko;
    constructor() {
        admin = msg.sender;
    }
    mapping (address => uint) stakeBalance;
    mapping (address => uint) stakeTime;
    mapping (address => uint) preEarn;
    
    event Stake(address indexed user, uint amount);
    event UnStake(address indexed user);
    event takeLeko(address indexed , uint amount);
    
    function setLEKOcontract(address _address) public {
        require(msg.sender == admin);
        leko = LEKOToken(_address);
    }
    function viewStakeBalance(address _user) public view returns(uint) {
        return stakeBalance[_user];
    }
    function viewStakeTime(address _user) public view returns(uint) {
        return stakeTime[_user];
    }
    function viewPreEarn(address _user) public view returns(uint) {
        return preEarn[_user];
    }
    function stake(uint _amount) public payable {
        require(msg.value == _amount*10**18);
        preEarn[msg.sender] += uint(block.timestamp - stakeTime[msg.sender])/uint(60) *10*stakeBalance[msg.sender];
        stakeBalance[msg.sender] += _amount;
        stakeTime[msg.sender] = block.timestamp;
        emit Stake(msg.sender, _amount);
    }
    function withdrawETH() public {
        address payable _user = payable(msg.sender);
        _user.transfer(stakeBalance[msg.sender]*10**18);
        preEarn[msg.sender] +=  uint(block.timestamp - stakeTime[_user])/uint(60) *10*stakeBalance[_user];
        stakeBalance[msg.sender] = 0;
        emit UnStake(msg.sender);
    }
    function viewReward(address _user) public view returns(uint) {
        uint _amount = preEarn[_user] + uint(block.timestamp - stakeTime[_user])/uint(60) *10*stakeBalance[_user];
        return _amount;
    }
    function withdrawLEKO() public {
        uint _amount = preEarn[msg.sender] + uint(block.timestamp - stakeTime[msg.sender])/uint(60) *10*stakeBalance[msg.sender];
        require(leko.transfer(msg.sender, _amount*10**18), "contract doesn't have enough LEKO");
        preEarn[msg.sender] = 0;
        stakeTime[msg.sender] = block.timestamp;
        emit takeLeko(msg.sender, _amount);
    }
}