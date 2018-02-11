pragma solidity ^0.4.0;

import "./auction.sol";

// multiple inheratance also supported 
// abstract classes also exist, 
//  dont implement all functions, can extend other classes, variables, constructors,
//  interfaces can only provide sigs
contract BaseAuction is Auction {
    address public owner;
    
    modifier ownerOnly() {
        require(msg.sender == owner);
        _;
    }
    
    event AuctionComplete(address winner, uint bid);
    
    function BaseAuction() public{
        owner = msg.sender;
    }
}