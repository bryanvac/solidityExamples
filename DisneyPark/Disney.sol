// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "./DisneyToken.sol";
import "./Safemath.sol";


contract Disney {

    struct Client {
        uint256 _tokensBuyed;
        uint256 _tokensSpent;
        uint256 _tokensRemaining;
        string [] _attractions;
    }


    DisneyToken private _token;
    address payable public _owner;
    mapping (address => Client) public usersDisney;
    uint256 tokensTotalbuyed;

    using SafeMath for uint;

    constructor() {
        _token = new DisneyToken();
        _owner = payable(msg.sender);
    }

    modifier isOwner(address _address) {
        require(msg.sender == _owner, "You are not the owner");
        _;
    }

    modifier isUser(address _address) {
        require(msg.sender != _owner, "You are the owner");
        _;
    }

    function priceTokens(uint _tokensAmount) internal pure returns (uint) {
        return _tokensAmount.mul(0.001 ether);
    }

    function buyTokensDisney(uint _tokensDisney) public payable returns (bool){
        require(msg.sender != _owner, "Owner Contract cant buy tokens");
        require(_tokensDisney > 0, "Number of tokens must be more than zero");
        require(_tokensDisney < _token.totalSupply(), "Tokens Disney not available");

        uint cost = priceTokens(_tokensDisney);
        require(msg.value > cost, "You dont have enough ether for this purchase");

        uint dif = msg.value - cost;

        payable(msg.sender).transfer(dif);
        _token.transfer(msg.sender, _tokensDisney);

        if(usersDisney[msg.sender]._tokensBuyed > 0) {
            usersDisney[msg.sender]._tokensBuyed.add(_tokensDisney);
            usersDisney[msg.sender]._tokensRemaining.add(_tokensDisney) ;
        }
        else {
            string [] memory attractions;
        
            Client memory client = Client(_tokensDisney,0,_tokensDisney,attractions);
            
            tokensTotalbuyed.add(_tokensDisney);
            usersDisney[msg.sender] = client;
        }

        return (true);

    }

    function balanceTokensUser() public view returns (uint){
        return usersDisney[msg.sender]._tokensBuyed;
    }

    function balanceTokensDisney() public view returns (uint){
        return _token.balanceOf(address(this));
    }

    function totalSuplyDisney() public view returns (uint){
        return _token.totalSupply();
    }

    event newAttraction(string);
    event enjoyAttraction(string);
    event damagedAttraction(string);

    struct Attraction {
        uint price;
        bool state;
    }

    mapping (string => Attraction) public _attractions;

    function addAttraction(string memory _name, uint _price) public isOwner(msg.sender) returns (bool){

        Attraction memory _attraction = Attraction(_price,true);
        _attractions[_name] = _attraction;
        
        emit newAttraction(_name);

        return (true);
    }

    function disableAttraction(string memory _name) public isOwner(msg.sender) returns (bool){
        require(_attractions[_name].state == true, "The attraction has already been disabled");
        _attractions[_name].state = false;

        return true;
    }

    function enabledAttraction(string memory _name) public isOwner(msg.sender) returns (bool){
        require(_attractions[_name].state == false, "The attraction has already been enabled");
        _attractions[_name].state = true;

        return true;
    }

    function isEnabledAttraction(string memory _name) public view returns (bool){
        return _attractions[_name].state;
    }

    function useAttraction(string memory _name) public payable isUser(msg.sender) returns (bool){
        require(_attractions[_name].state == true, "The attraction is disabled, use other attraction");
        require(usersDisney[msg.sender]._tokensBuyed > _attractions[_name].price, "You dont have enough tokens") ;

        //TO DO
    
    }
}