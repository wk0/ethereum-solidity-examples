pragma solidity ^0.4.0;

contract Election {
    
    struct Candidate {
        string name;
        uint voteCount;
    }
    
    struct Voter {
        bool voted;
        uint vote;
        uint weight;
    }
    
    string public name;
    address public owner;
    
    mapping(address => Voter) public voters;
    Candidate[] public candidates;
    
    event ElectionResult(string name, uint voteCount);
    
    // no nested arrays, strings are arrays
    function Election(string _name, string name1, string name2){
        owner = msg.sender;
        name = _name;
        
        candidates.push(Candidate({name: name1, voteCount: 0}));
        candidates.push(Candidate({name: name2, voteCount: 0}));
    }
    
    function authorize(address voter){
        require(msg.sender == owner);
        require(!voters[voter].voted);
        
        //only authorized voters
        voters[voter].weight = 1;
    }
    
    function vote(uint voteIndex){
        require(!voters[msg.sender].voted);
        
        voters[msg.sender].vote = voteIndex;
        voters[msg.sender].voted = true;
        
        candidates[voteIndex].voteCount += voters[msg.sender].weight;
    }
    
    function end(){
        require(msg.sender == owner);
        
        for(uint i=0; i< candidates.length; i++){
            ElectionResult(candidates[i].name, candidates[i].voteCount);
        }
        
        // any future eth sent here is gone forever
        selfdestruct(owner);
    }
}