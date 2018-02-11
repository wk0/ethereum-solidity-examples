pragma solidity ^0.4.18;

import "./withdrawable.sol";

/*
    Two player betting game, both guess random number between 1 and 100 inclusive,
    whoever guesses closest is the winner
*/

contract RandomNumberBetter is Withdrawable{
    uint public constant MIN_GUESS = 1;
    uint public constant MAX_GUESS = 100;
    
    enum State {WAGER_OPEN, WAGER_SET, COMPLETE}
    
    State public currentState;
    address public player1;
    address public player2;
    uint public wager;
    mapping(address=>uint) guesses;
    uint public minWager;
    uint public maxWager;
    bytes32 public seedHash;
    
    modifier playersOnly(){
        require(msg.sender == player1 || msg.sender == player2);
        _;
    }
    
    modifier inState(State expectedState){
        require(currentState == expectedState);
        _;
    }
    
    event StatusUpdate(string update);
    
    function RandomNumberBetter(address _player1, address _player2, uint _minWager, uint _maxWager){
        require(_minWager < _maxWager);
        
        player1 = _player1;
        player2 = _player2;
        minWager= _minWager;
        maxWager= _maxWager;
        StatusUpdate("wager open");
        seedHash = block.blockhash(block.number -1);
    }
    
    // Problem that second player can see first players guess, can be advantageous 
    //    probably needs encryption ahead of time
    function submitWager(uint guess) playersOnly inState(State.WAGER_OPEN) payable public {
        require(guess >= MIN_GUESS && guess <= MAX_GUESS);
        require(msg.value >= minWager && msg.value <= maxWager);
        
        if (wager==0){
            wager = msg.value;
            guesses[msg.sender] = guess;
            StatusUpdate("wager accepted");
            return;
        }
        
        require(msg.value == wager);
        require(guesses[msg.sender] == 0);
        
        guesses[msg.sender] = guess;
        currentState = State.WAGER_SET;
        StatusUpdate("wager set");
    }
    
    function resolveWager() playersOnly inState(State.WAGER_SET) public {
        uint randomNumber = (rand()%MAX_GUESS)+1;
        
        int player1Diff = int(randomNumber - guesses[player1]);
        int player2Diff = int(randomNumber - guesses[player2]);
        if(player1Diff < 0) player1Diff *= -1;
        if(player2Diff < 0) player2Diff *= -1;
        
        if (player1Diff == player2Diff){
            pendingWithdrawals[player1] = this.balance/2;
            pendingWithdrawals[player2] = this.balance/2;
            StatusUpdate("Game draw");
        }
        else if (player1Diff < player2Diff){
            pendingWithdrawals[player1] = this.balance;
            StatusUpdate('Player 1 wins!');
        }
        else {
            pendingWithdrawals[player2] = this.balance;
            StatusUpdate("Player 2 wins!");
        }
        
        currentState = State.COMPLETE;
    }
    
    // Questionable how secure this is
    function rand() private returns (uint) {
        uint seedInt = uint(seedHash)/2; //dont want int overflow w/ salt
        seedInt += now;
        return uint(sha256(seedInt));
    }
}