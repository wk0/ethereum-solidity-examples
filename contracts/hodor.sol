pragma solidity ^0.4.0;

/*
A simple project that returns a greeting
*/
contract Hodor {
    address creator;
    string greeting;

    function Hodor(string _greeting) public {
        greeting = _greeting;
        creator = msg.sender;
    }
    
    // returns the current greeting
    function greet() public constant returns (string) {
        return greeting;
    }
    
    // changes the current greeting 
    function setGreeting(string _greeting) public {
        greeting = _greeting;
    }
}