
# Homework 20


## Conditions of contract
```js
- they need to send 1 ETH to join
- 200 players
- Once 200 players have entered, the UI will be notified by the
    payDividends event, which will then pick the top investors and pay them
    some dividends.
- The remaining balance will be kept as profit for the developers."
```

========================================


- [1] Lack of zero address checks on ecrecover
- [2] Initialized variables
- [3] Unused variables
- [4] Variables not updated
- [5] The same person can call the same function more than once
- [6] Use tx.origin instead of msg.sender
- [7] Error in the msg.value request
- [8] Anyone can call the function "makePayout" and "payOutDividends".
- [9] Logical error in the distribution of funds
- [10] Bad implementation of the "for" loop
- [11] the use of transfer may have some limitations in case the receiver is a contract with a fallback function.

========================================

## [1] Lack of zero address checks on ecrecover

### Proof of concept

- It does not use a check that the address(0) account cannot call the function.

```js
    function addInvestor(address payable _investor) public payable { 

```
### Recommendation:
```js
add require(msg.sender != address(0), "is zero address!");
```

## [2] Initialized variables

### Proof of concept

- By not initializing variables, problems arise during the code.
```js
address public role; 
```

### Recommendation:
- Initialize the variable in the constructor 

## [3] Unused variables

### Proof of concept

- There are variables that are never used and this causes the code to malfunction.
- Certain functions need to use these variables for their correct operation.

```js
numberInvestors


```
### Recommendation:
 - Use inactive variables or delete them if necessary.


 ## [4] Variables not updated

### Proof of concept

- Failure to update variables leads to a loss of the function logic and generates bad behavior triggering problems.


- numberInvestors is never updated
    - this means that the number of investors is never counted.
    - Will never call A if (numberInvestors > 200) as it will always be 0.
```js
 function addInvestor(address payable _investor) public payable {  

        if(msg.value == 2);  
            investors.push(_investor);
            currentDividend ++;
            numberInvestors ++;
        
        if (numberInvestors > 200) {
            makePayout(100);
            emit payDividends(200);
        }

    }
```
### Recommendation:

```js
 function addInvestor(address payable _investor) public payable {  
        if(msg.value == 2); 
            investors.push(_investor);
            currentDividend ++;

        
        if (numberInvestors > 200) {
            makePayout(100);
            emit payDividends(200);
        }

    }
```

## [5] The same person can call the same function more than once

### Proof of concept

The same person can call the same function more than once, creating an accounting problem.

```js
 function addInvestor(address payable _investor) public payable {  

        if(msg.value == 2);  
            investors.push(_investor);
            currentDividend ++;
            numberInvestors ++;
        
        if (numberInvestors > 200) {
            makePayout(100);
            emit payDividends(200);
        }

    }
```
### Recommendation:

- Use a mapping to find out if a person called the function or not

```js
    mapping(address => bool) public authorized;

    function addInvestor(address payable _investor) public payable {  
        require(!authorized[msg.sender], "Already authorized");

        if(msg.value == 2); 
            investors.push(_investor);
            currentDividend ++;
            numberInvestors ++;

        
        if (numberInvestors > 200) {
            makePayout(100);
            emit payDividends(200);
        }
        authorized[msg.sender] = true;

    }
```

## [6] Use tx.origin instead of msg.sender

### Proof of concept

```js
  modifier onlyAdmin(){ 
        if (tx.origin==role){  //@audit => //never initialice
            _;
        }
    }
```

### Recommendation:
```js
  modifier onlyAdmin(){ 
        if (msg.sender==role){ 
            _;
        }
    }
```

## [7] Error in the msg.value request

### Proof of concept

- Orders 2 Wei instead of 1 ETH

```js
if(msg.value == 2);
```

### Recommendation:

```js
if(msg.value == 1 eth);
```

## [8] Anyone can call the function "makePayout" and "payOutDividends".

### Proof of concept

- Since they are public variables and the modifier does not work, anyone can call the function.


### Recommendation:

- Change the public one to internal since both functions are called through addInvestor.

- You can make it external but apply drivers and more security requirements.


## [9] Logical error in the distribution of funds

### Proof of concept

- Will always be 0

```js
    uint256 amountToPay = numberInvestors/ 100; // = 0
    uint256 currentDividend = _amount / dividendRate; // = 0

```

### Recommendation:

- Correct use of the numberInvestors variable


## [10] Bad implementation of the "for" loop

### Proof of concept

- Bad implementation of the "for" loop, allowing to take values out of range.
- loop condition is i <= investors.length, it will allow index i to take the value of investors.length, which is out of range. 

```js
for (uint256 i = 0; i <= investors.length; i++) {
```

### Recommendation:

- In Solidity, arrays are indexed from 0 to length - 1, so accessing investorsinvestors.length will cause an out-of-range index error. 

- Therefore, the necessary fix is to change the loop condition to i < investors.length to ensure that only valid indexes are accessed.

```js
uint256 inv = investors.length;
for (uint256 i = 0; i < inv; i++) {
```

## [11] the use of transfer may have some limitations in case the receiver is a contract with a fallback function.

### Proof of concept

- transfer may have some limitations in case the receiver is a contract with an expensive fallback function or if the gas limit is exceeded during the transfer execution.

### Recommendation:

- Verify that the caller is not a contract



# Test code

```js
contract ContractTestPuppy is Test {

    PuppyCoinGame puppy;
    address admin = vm.addr(1);
    address bob = vm.addr(2);
    address alice = vm.addr(3);


    function setUp() public {

        vm.prank(admin);
        puppy = new PuppyCoinGame();
    }

    function testverify () public {

        console.log("ROLE",puppy.role());
        puppy.currentDividend();
        // puppy.dividendRate();
        puppy.numberInvestors();
    }


    function testFuzz_stateOwner(address payable randomSender) public {
        vm.assume(randomSender  != address(0));

        for (uint256 i= 0; i < 200; ++i) {
            puppy.addInvestor{value : 2 }(randomSender);
        }
        assertEq(address(puppy).balance, 400);
        console.log("Balance Before",(address(alice).balance));


        // console.log("N Investors",puppy.numberInvestors());
        // console.log("currentDividend", puppy.currentDividend());
    }

    function testCallOnlyadmin () public {
        vm.deal(bob, 1000 ether);
        // vm.expectRevert()
        vm.prank(address(0));
        puppy.makePayout(100);

    }

    function testFuzz_Past(address payable randomSender) public {
        vm.assume(randomSender  != address(0));
        vm.deal(alice, 2 ether );

        for (uint256 i= 0; i < 199; ++i) {
            puppy.addInvestor{value : 2 }(randomSender);
        }

        vm.prank(alice);
        puppy.addInvestor{value : 2 }(payable(address(alice)));

        assertEq(address(puppy).balance, 400);
        console.log("Balance Before",(address(alice).balance));

        vm.prank(alice);
        puppy.payOutDividends(400);
        console.log("Balance After",(address(alice).balance));

        // console.log("N Investors",puppy.numberInvestors());
        // console.log("currentDividend", puppy.currentDividend());
    }
}
```


# Comments in code

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/forge-std/src/Test.sol";



contract PuppyCoinGame is ERC20 {
    uint256 public currentDividend;        
    uint256 dividendRate = 12;  // dividend rate of 12%      
    address payable[] public investors;   
    address public role;     //@audit => never inintialice  == address(0)                
    uint256 public numberInvestors = 0;  //@audit => Does not count the number of investors
    event payDividends(uint256 indexed);

    // mapping(address => bool) public authorized;

    constructor() ERC20("PuppyCoin", "PUC") {
        dividendRate = 12;
    }

    modifier onlyAdmin(){ 
        if (tx.origin==role){  //@audit => //never initialice
            _;
        }
    }

    function addInvestor(address payable _investor) public payable { //@audit => function can be called more than 1 time by the same person
        // require(!authorized[msg.sender], "Already authorized");

        // require(msg.value == 2, "NECESITAS MAS"); 
        if(msg.value == 2); //@audit => masg.value != 2, is ==1 
            investors.push(_investor);
            currentDividend ++;
        
        if (numberInvestors > 200) {
            makePayout(100);
            emit payDividends(200);
        }
        // authorized[msg.sender] = true;

    }



    function makePayout(uint256 _payees) public onlyAdmin {
        if (address(this).balance == 100) {
            uint256 amountToPay = numberInvestors/ 100; //@audit => will always be o
            payOutDividends(amountToPay);
        }
    }

    function payOutDividends(uint256 _amount) public {

        uint256 currentDividend = _amount / dividendRate; //@audit => 0
        for (uint256 i = 0; i <= investors.length; i++) { //audit => i<
            investors[i].transfer(currentDividend); // audit => use a modifier investors != address(contract)
        }
    }
}
```
