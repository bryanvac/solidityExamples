// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;
pragma experimental ABIEncoderV2;

/*
Create vote new
    Name vote
    Candidates 
    Max Votes
    Current votes
    Votes List
    VoteDetail
    TypeVote // private or public
    Options  // list string with posible values
Vote data
    Voter  // if typeVote is public
    VoteValue // value vote

Creater voter Data

*/
//import "github.com/Arachnid/solidity-stringutils/strings.sol";

contract VotingSystem {

    //using strings for *;
    struct slice {
        uint _len;
        uint _ptr;
    }

    enum TypeVote { PUBLIC, PRIVATE }

    struct VoteDetail {
        string voter; 
        string voteValue; 
    }

    

    struct VoteData {
        string nameVotation;
        bool created;
        address addresOwnerVotation;
        uint32 maxVotes;
        uint32 currentVotes;
        TypeVote typeVote; 
        string [] optionsVote;
        string [] candidatesName;
        mapping (string => uint8) candidatesVotes;
        mapping (address => string) votes; 
    }

    mapping (uint8 => VoteData) votations;

    uint8 counterVotationsForIds;
    address ownerVotingSystem;

    constructor() {
        counterVotationsForIds = 0;
        ownerVotingSystem = msg.sender;
    }

    function createVotation(string memory _voteName, uint32 _maxVotes, TypeVote _typeVote) public returns (uint){
        require (getHash(_voteName) != getHash('') ,"Need a name for votation" );
        address votingOwner = msg.sender;
        
        string [] memory optionsVote;
        string [] memory candidatesName;
        //mapping (string => uint8) memory candidates;
        //mapping (address => string) memory votes; 
        
        VoteData storage voteData =  votations[counterVotationsForIds];
        
        voteData.nameVotation = _voteName;
        voteData.created = true;
        voteData.addresOwnerVotation = votingOwner;
        voteData.maxVotes = _maxVotes;
        voteData.currentVotes = 0;
        voteData.typeVote = _typeVote;
        voteData.optionsVote = optionsVote;
        voteData.candidatesName = candidatesName;
        
        pushOptionsVoting(counterVotationsForIds);

        counterVotationsForIds++;
        return counterVotationsForIds-1;
    }

    function pushOptionsVoting (uint8 idVoting) private{ // TODO add parameter string memory _optionsVote

        votations[idVoting].optionsVote.push("SI");
        votations[idVoting].optionsVote.push("NO");
        /*slice memory optionsVote = _optionsVote.toSlice();    
        slice memory regex = " ".toSlice();
        
        for(uint i = 0; i < optionsVote.count(regex) + 1; i++) {
            votations[ownerVoting].optionsVote.push(optionsVote.split(regex).toString());
        }*/
    }

    function addCandidates (uint8 _idVoting, string memory _member) public returns (string memory, string memory){
        require (votations[_idVoting].created,"Voting doesnt exists" );
        require (votations[_idVoting].addresOwnerVotation == msg.sender ,"You dont have permissions" );
        require(!existCandidate(votations[_idVoting].candidatesName, _member), "Candidate already exists");

        votations[_idVoting].candidatesVotes[_member] = 0;
        votations[_idVoting].candidatesName.push(_member);

        return (votations[_idVoting].nameVotation , _member)  ;
    }

    function getCandidates ( uint8 _idVoting) public view returns (string[] memory){
        require (votations[_idVoting].created,"Voting doesnt exists" );

        return votations[_idVoting].candidatesName;
    }
    
    function voteCandidate (uint8 _idVoting, string memory _candidate) public returns (bool){
        require (votations[_idVoting].created,"Voting doesnt exists" );
        require(existCandidate(votations[_idVoting].candidatesName, _candidate), "Candidate doesnt exists");

        votations[_idVoting].candidatesVotes[_candidate]++;

        return true;
    }

    function getNumberVotesCandidate (uint8 _idVoting, string memory _candidate) public view returns (uint8){
        require (votations[_idVoting].created,"Voting doesnt exists" );
        require(existCandidate(votations[_idVoting].candidatesName, _candidate), "Candidate doesnt exists");

        return votations[_idVoting].candidatesVotes[_candidate];
    }

    function getResults (uint8 _idVoting) public payable returns (string [] memory candidates, uint8 [] memory votes){
        require (votations[_idVoting].created,"Voting doesnt exists" );
        require (votations[_idVoting].addresOwnerVotation == msg.sender ,"You dont have permissions" );

        
        string [] memory _candidates;
        uint8 [] memory _votes;

        for (uint i = 0 ; i < votations[_idVoting].candidatesName.length ; i++){
            string memory name = votations[_idVoting].candidatesName[i];
            _candidates[i] = name;
            _votes[i] = votations[_idVoting].candidatesVotes[name];
        }
        

        return (candidates,votes);
    }

    function existCandidate(string[] memory _candidates, string memory _candidate) private pure returns (bool){

        for (uint i; i < _candidates.length ; i++){
            if(getHash(_candidates[i]) == getHash(_candidate)){
                return true;
            }
        }

        return false;
    }

    function getHash(string memory _name)  private pure returns (bytes32) {
        return keccak256(abi.encodePacked(_name));
    }
    
}