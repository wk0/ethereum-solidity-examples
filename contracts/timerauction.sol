pragma solidity ^0.4.0;

import './withdrawable.sol';

contract TimerAuction is Withdrawable{
    address public owner;
    string public item;
    uint public auctionEnd;
    address public maxBidder;
    uint public maxBid;
    bool public ended;

    modifier ownerOnly() {
        require(msg.sender == owner);
        _;
    }

    event AuctionComplete(address winner, uint bid);
    event BidAccepted(address bidder, uint bid);

    function TimerAuction(uint _durationMinutes, string _item) public {
        owner = msg.sender;
        item = _item;
        // now is an alias to block.timestamp property, seconds since epoch
        // solidity has day, months, seconds
        auctionEnd = now + (_durationMinutes * 1 minutes);
    }   
    
    function bid() payable{
        require(now < auctionEnd);
        require(msg.value > maxBid);
        
        if (maxBidder != 0){
            pendingWithdrawals[maxBidder] = maxBid;
        }
        
        maxBidder = msg.sender;
        maxBid = msg.value;
        BidAccepted(maxBidder, maxBid);
    }
    
    function end() ownerOnly{
        // 1) check conditions
        require(!ended);
        require(now >= auctionEnd);
        
        // 2) update state
        ended = true;
        AuctionComplete(maxBidder, maxBid);
        
        // 3) interact with address
        pendingWithdrawals[owner] = maxBid;
    }
    
}

/*

transfer is insecure because you dont know if the function calling is a smart contract
or a normal address

if smart contract, will invoke fallback function
   takes zero arguments

fallback needs to be payable to accept ether
   will throw exception if no fallback, eg put into weird state

*/