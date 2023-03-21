# Homework 10

- [file:///Users/secoalba/Downloads/Homework10.pdf]

## Code + Contract Test

```js
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

import "lib/forge-std/src/Test.sol";

contract DogCoin {

    event SupplyIncreased(uint256 newTotalSupply);
    event Transfer(address indexed from, address indexed to, uint256 value);


    uint256 public totalSupply = 2000000; // 2 million
    
    address public owner;
    
    mapping(address => uint256) public balances; // mapping to store user balances
    
    mapping(address => Payment[]) payments;// mapping to track payments for each user

        
    modifier onlyOwner() {
        require(msg.sender == owner, "No Owner");
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

    //add function _mint
    function mint() public payable onlyOwner{
        require(msg.value == 1000,"Incorrect value");
        require(msg.sender != address(0));
        _mint(msg.value);

    }
      function _mint(uint256 amount) internal {
        totalSupply += amount;
        balances[owner] += amount;
        emit SupplyIncreased(totalSupply);
    }
     
}
contract ContractTestDog is Test {

    DogCoin dogCoin;
    address bob;
    address alice;

    function setUp() public {
        dogCoin = new DogCoin();
        // vm.deal(address(dogCoin), 5 ether); 
        bob = vm.addr(1);
        alice = vm.addr(2);

        vm.deal(bob, 2 ether);
        vm.deal(alice, 2 ether);

    }

    function testTotalSupply() public {
        console.log("TotalSupply", dogCoin.totalSupply());
        assertEq(dogCoin.getTotalSupply(), dogCoin.totalSupply());
    }

    function testIncrementSupply() public {
        console.log("Total Supply Before", dogCoin.getTotalSupply());
        dogCoin.mint{value:1000}();
        assertEq(dogCoin.getTotalSupply(), (2000000 + 1000));
        console.log("Total Supply After", dogCoin.getTotalSupply());
    }

    function testIncrementSupplyNoOwner() public {
        console.log("Total Supply Before", dogCoin.getTotalSupply());
        console.log("Player alice before1",dogCoin.balances(alice));

        dogCoin.transfer(1000, alice);
        console.log("Player alice before2",dogCoin.balances(alice));


        vm.expectRevert("No Owner");
        vm.prank(alice);
        dogCoin.mint{value: 1000}();
        
        console.log("Total Supply After", dogCoin.getTotalSupply());

    }


    function testTransfer() public {
        console.log("Player alice",dogCoin.balances(alice));
        console.log("Total Supply Before", dogCoin.getTotalSupply());

        dogCoin.transfer(100, alice);
        assertEq(dogCoin.balances(alice),100);

        console.log("Player alice",dogCoin.balances(alice));

    }

    function testTransferFail() public {
        console.log("Player alice",dogCoin.balances(alice));
        console.log("Player bob",dogCoin.balances(bob));

        vm.expectRevert("Insufficient balance.");
        
        vm.prank(alice);
        dogCoin.transfer((1 ether), bob);
        console.log("Player alice",dogCoin.balances(alice));
        console.log("Player bob",dogCoin.balances(bob));

    } 
}
```

## Test Result

```js
Running 5 tests for test/DogCoin.sol:ContractTestDog
[PASS] testIncrementSupply() (gas: 32091)
Logs:
  Total Supply Before 2000000
  Total Supply After 2001000

Traces:
  [32091] ContractTestDog::testIncrementSupply() 
    ├─ [2325] DogCoin::getTotalSupply() [staticcall]
    │   └─ ← 2000000
    ├─ [0] console::9710a9d0(000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000001e84800000000000000000000000000000000000000000000000000000000000000013546f74616c20537570706c79204265666f726500000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [11877] DogCoin::mint{value: 1000}() 
    │   ├─ emit SupplyIncreased(newTotalSupply: 2001000)
    │   └─ ← ()
    ├─ [325] DogCoin::getTotalSupply() [staticcall]
    │   └─ ← 2001000
    ├─ [325] DogCoin::getTotalSupply() [staticcall]
    │   └─ ← 2001000
    ├─ [0] console::9710a9d0(000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000001e88680000000000000000000000000000000000000000000000000000000000000012546f74616c20537570706c792041667465720000000000000000000000000000) [staticcall]
    │   └─ ← ()
    └─ ← ()

[PASS] testIncrementSupplyNoOwner() (gas: 127889)
Logs:
  Total Supply Before 2000000
  Player alice before1 0
  Player alice before2 1000
  Total Supply After 2000000

Traces:
  [127889] ContractTestDog::testIncrementSupplyNoOwner() 
    ├─ [2325] DogCoin::getTotalSupply() [staticcall]
    │   └─ ← 2000000
    ├─ [0] console::9710a9d0(000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000001e84800000000000000000000000000000000000000000000000000000000000000013546f74616c20537570706c79204265666f726500000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [2553] DogCoin::balances(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014506c6179657220616c696365206265666f726531000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [94566] DogCoin::transfer(1000, 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) 
    │   ├─ emit Transfer(from: ContractTestDog: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], to: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, value: 1000)
    │   └─ ← true
    ├─ [553] DogCoin::balances(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 1000
    ├─ [0] console::9710a9d0(000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000003e80000000000000000000000000000000000000000000000000000000000000014506c6179657220616c696365206265666f726532000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [0] VM::expectRevert(No Owner) 
    │   └─ ← ()
    ├─ [0] VM::prank(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) 
    │   └─ ← ()
    ├─ [2363] DogCoin::mint{value: 1000}() 
    │   └─ ← "No Owner"
    ├─ [325] DogCoin::getTotalSupply() [staticcall]
    │   └─ ← 2000000
    ├─ [0] console::9710a9d0(000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000001e84800000000000000000000000000000000000000000000000000000000000000012546f74616c20537570706c792041667465720000000000000000000000000000) [staticcall]
    │   └─ ← ()
    └─ ← ()

[PASS] testTotalSupply() (gas: 12304)
Logs:
  TotalSupply 2000000

Traces:
  [12304] ContractTestDog::testTotalSupply() 
    ├─ [2307] DogCoin::totalSupply() [staticcall]
    │   └─ ← 2000000
    ├─ [0] console::9710a9d0(000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000001e8480000000000000000000000000000000000000000000000000000000000000000b546f74616c537570706c79000000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [325] DogCoin::getTotalSupply() [staticcall]
    │   └─ ← 2000000
    ├─ [307] DogCoin::totalSupply() [staticcall]
    │   └─ ← 2000000
    └─ ← ()

[PASS] testTransfer() (gas: 114682)
Logs:
  Player alice 0
  Total Supply Before 2000000
  Player alice 100

Traces:
  [114682] ContractTestDog::testTransfer() 
    ├─ [2553] DogCoin::balances(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c506c6179657220616c6963650000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [2325] DogCoin::getTotalSupply() [staticcall]
    │   └─ ← 2000000
    ├─ [0] console::9710a9d0(000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000001e84800000000000000000000000000000000000000000000000000000000000000013546f74616c20537570706c79204265666f726500000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [94566] DogCoin::transfer(100, 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) 
    │   ├─ emit Transfer(from: ContractTestDog: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], to: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, value: 100)
    │   └─ ← true
    ├─ [553] DogCoin::balances(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 100
    ├─ [553] DogCoin::balances(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 100
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000064000000000000000000000000000000000000000000000000000000000000000c506c6179657220616c6963650000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    └─ ← ()

[PASS] testTransferFail() (gas: 27160)
Logs:
  Player alice 0
  Player bob 0
  Player alice 0
  Player bob 0

Traces:
  [27160] ContractTestDog::testTransferFail() 
    ├─ [2553] DogCoin::balances(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c506c6179657220616c6963650000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [2553] DogCoin::balances(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a506c6179657220626f6200000000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [0] VM::expectRevert(Insufficient balance.) 
    │   └─ ← ()
    ├─ [0] VM::prank(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) 
    │   └─ ← ()
    ├─ [657] DogCoin::transfer(1000000000000000000, 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) 
    │   └─ ← "Insufficient balance."
    ├─ [553] DogCoin::balances(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c506c6179657220616c6963650000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [553] DogCoin::balances(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a506c6179657220626f6200000000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    └─ ← ()

Test result: ok. 5 passed; 0 failed; finished in 4.58ms
```