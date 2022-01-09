pragma solidity >=0.4.4;
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

    enum TypeVote { PRIVATE, PUBLIC }

    struct VoteDetail {
        string voter; 
        string voteValue; 
    }

    struct VoteData {
        string nameVotation;
        bool created;
        address addresOwnerVotation;
        string [] candidates;
        uint32 maxVotes;
        uint32 currentVotes;
        TypeVote typeVote; 
        string [] optionsVote;
        string [] votes; // must be VoteDetail no string
    }

    mapping (uint8 => VoteData) votations;

    uint8 counterVotationsForIds;
    address ownerVotingSystem;

    constructor() {
        counterVotationsForIds = 0;
        ownerVotingSystem = msg.sender;
    }

    function createVotation(string memory _voteName, uint32 _maxVotes, TypeVote _typeVote) public returns (VoteData memory){
        address votingOwner = msg.sender;
        
        
        string [] memory options;
        string [] memory optionsVote;
        string [] memory votes;
        
        VoteData memory voteData = VoteData(_voteName,true,votingOwner,options,_maxVotes, 0,_typeVote, optionsVote,votes);
        
        votations[counterVotationsForIds]=voteData;
        pushOptionsVoting(counterVotationsForIds);

        counterVotationsForIds++;
        return votations[counterVotationsForIds];
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

    function addCandidates (uint8 _idVoting, string memory _member) public returns (VoteData memory){
        require (votations[_idVoting].created,"Voting doesnt exists" );
        require (votations[_idVoting].addresOwnerVotation == msg.sender ,"You dont have permissions" );
        require(!existCandidate(votations[_idVoting].candidates, _member), "Candidate already exists");

        votations[_idVoting].candidates.push(_member);

        return votations[_idVoting];
    }

    function getCandidates ( uint8 _idVoting) public view returns (string[] memory){
        require (votations[_idVoting].created,"Voting doesnt exists" );

        return votations[_idVoting].candidates;
    }
    
    function voteCandidate (uint8 _idVoting, string memory _candidate) public returns (bool){
        require (votations[_idVoting].created,"Voting doesnt exists" );
        require(existCandidate(votations[_idVoting].candidates, _candidate), "Candidate doesnt exists");

        votations[_idVoting].votes.push(_candidate);

        return true;
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