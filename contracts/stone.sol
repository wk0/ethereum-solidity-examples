pragma solidity ^0.4.0;

/*
Currency that can only be issued by its creator and transferred to anyone
*/

contract Stone {
    address public creator;
    // NOTE: uint, cant have fractional Stone
    mapping (address => uint) public balances;

    // updated to have ether price
    uint public PRICE = 3000000000000000000;

    // event that notifies when transfer has completed
    event Delivered(address from, address to, uint amount);
    
    function Stone() public {
        creator = msg.sender;
    }
    
    function create() payable public {
        require(msg.value > 0 && msg.value % PRICE == 0);
        balances[msg.sender] += (msg.value / PRICE);
    }
    
    function transfer(address reciever, uint amount) public {
        if (balances[msg.sender] < amount) return;
        balances[msg.sender] -= amount;
        balances[reciever] += amount;
        Delivered(msg.sender, reciever, amount);
    }
}

/*

    // The mapping above basically makes this function
    //      simple map from account to uint 
    function balances(address _amount) returns (uint) {
        return balances[_account];
    }
    

*/