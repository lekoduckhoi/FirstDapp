pragma solidity ^0.8.3;

import "./LEKO.sol";

contract betting {
    address admin;
    LEKOToken leko;
    constructor() {
        admin = msg.sender;
    }
    
    //Track one User's profit
   
    mapping (address => int) TotalProfitOfUsers;
    
    function viewTotalProfit(address _address) public view returns(int) {
        return TotalProfitOfUsers[_address];
    }
    
    //Track Top5 latest bet // function view write in javascript by watching event by number
    
    event Bet(uint indexed number, address user, int amount, int profit);
    uint numberOfBets = 0;
    
    function viewLastBetId() public view returns(uint) {
        return numberOfBets;
    }
    
    //Track Top5 profitable user // function view by track most profit in profitList => id => address=  betUsers[id]
    
    address[] betUsers;
    int[] profitList;
    mapping (address => bool) hasBet;
    mapping (address => uint) idInBetUsers;
    
    function viewprofitList() public view returns(int[] memory) {
        return profitList;
    }
    
    // function set setLEKOcontract
    
    function setLEKOcontract(address _address) public {
        require(msg.sender == admin);
        leko = LEKOToken(_address);
    }
    
    // createRandomNumber
    
    function createRandomNumber() public view returns(uint) {
        uint rand = uint(keccak256(abi.encodePacked("leko", block.timestamp)))%100;
        return rand;
    }
    
    // function bet
    
    function bet(uint amount, uint _winchance) public {
        int _amount = int(amount);
        require(leko.transferFrom(msg.sender, address(this), amount*10**18), "cant take Leko");
        int _profit;
        uint _rand = createRandomNumber();
        if (_rand <= _winchance) {
            uint earn = amount*100/_winchance;
            int _earn = int(earn);
            _profit = _earn - _amount;
            require(leko.transfer(msg.sender, earn*10**18), "this contract doesn't have enough LEKO");
        } else {
            _profit = _amount*(-1);
        }
        
        //Track one User's profit
        
        TotalProfitOfUsers[msg.sender] += _profit;
        
        //Track one User's profit
        
        numberOfBets++;
        emit Bet(numberOfBets, msg.sender, _amount, _profit);
        
        //Track Top5 profitable user
        
        if(hasBet[msg.sender] == false){
            hasBet[msg.sender] = true;
            idInBetUsers[msg.sender] = betUsers.length;
            betUsers.push(msg.sender);
            profitList.push(_profit);
        } else {
            profitList[idInBetUsers[msg.sender]] += _profit;
        }
    }

}