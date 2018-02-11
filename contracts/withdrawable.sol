pragma solidity ^0.4.0;

contract Withdrawable {
    mapping(address=>uint) public pendingWithdrawals;

    function withdraw() public returns(bool){
        uint amount = pendingWithdrawals[msg.sender];
        if (amount > 0){
            pendingWithdrawals[msg.sender] = 0;
            
            if (!msg.sender.send(amount)){
                // thowing an error would eat transaction gas, so throw bool
                pendingWithdrawals[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }
}
    