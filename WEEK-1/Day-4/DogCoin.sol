// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

contract DogCoin {

    event SupplyIncreased(uint256 newTotalSupply);
    event Transfer(address indexed from, address indexed to, uint256 value);


    uint256 public totalSupply = 2000000; // 2 million
    
    address public owner;
    
    mapping(address => uint256) public balances; // mapping to store user balances
    
    mapping(address => Payment[]) payments;// mapping to track payments for each user
        
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        balances[owner] = totalSupply;
    }
    
    function increaseTotalSupply() public onlyOwner {
        totalSupply += 1000;
        emit SupplyIncreased(totalSupply);
    }
    
    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function getBalances(address user) public view returns (uint256) {
        return balances[user];
    }

    function transfer(uint256 amount, address recipient) public returns (bool) {
        require(amount <= balances[msg.sender], "Insufficient balance.");
        require(recipient != address(0), "Invalid recipient address.");

        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        
        // add payment to recipient's history
        payments[recipient].push(Payment(amount, msg.sender));

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // define Payment struct
    struct Payment {
        uint256 amount;
        address recipient;
    }


    // function to get payment history for a user
    function getPaymentHistory(address user) public view returns (Payment[] memory) {
        return payments[user];
    }

     

    
}
