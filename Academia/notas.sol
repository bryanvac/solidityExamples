pragma solidity >=0.4.4;
pragma experimental ABIEncoderV2;

// nombre, id y notas

contract Notes {

    struct Student {
        string name;
        bool created;
        bool qualified;
        uint8 note;
    }

    address public teacherAddress;

    mapping ( bytes32 => Student) public students ;

    string [] reviews;

    event studentsEvaluated(bytes32);
    event reviewsRequested(string);

    uint32 counterStudents;


    constructor () public {
        teacherAddress = msg.sender;
    }

    function addNotes(string memory _name, uint8 _note ) public isTeacher() returns ( Student memory ) {

        require (students[getHashName(_name)].created,"Student dont exists" );

        students[getHashName(_name)].note = _note;
        students[getHashName(_name)].qualified = true;

        emit studentsEvaluated(getHashName(_name));

        return students[getHashName(_name)];
    }

    function addStudent(string memory _name ) public isTeacher()  returns (bool) {

        require (!students[getHashName(_name)].created,"Student already exists" );

        students[getHashName(_name)] = Student(_name, true, false, 0 );

        return true;
    }

    function getMyNote(string memory _name) public returns (uint8){
        
        require (students[getHashName(_name)].created,"Student dont exists" );

        return students[getHashName(_name)].note;
    }

    function requestRevision (string memory _name) public {

        require (students[getHashName(_name)].created,"Student dont exists" );

        reviews.push(_name);

        emit reviewsRequested(_name);
    }

    function viewRevisions () public view isTeacher() returns ( string[] memory){
        
        return reviews;

    }

    function getHashName(string memory _name) pure private returns (bytes32) {
        return keccak256(abi.encodePacked(_name));
    }

    modifier isTeacher() {
        require(msg.sender == teacherAddress, "You don't have permissions");
        _;
    }

}