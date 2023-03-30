# Homework 15

## Code

```js

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/security/Pausable.sol";

import "lib/forge-std/src/Test.sol";
import "lib/forge-std/test/StdError.t.sol";



contract BadgerCoin is ERC20, Pausable {

    address owner;

    constructor() ERC20("BadgerCoin", "BC") {
        owner = msg.sender;
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function _pause() internal virtual override whenNotPaused {
        super._pause();
    }

    function _unpause() internal virtual override whenPaused {
        super._unpause();
    }

    function paused() public view virtual override returns (bool) {
        return super.paused();
    }


   function mint(address account, uint256 amount) public whenNotPaused{
        _mint(account, amount);
   }

    function approve(address spender, uint256 value) public virtual override whenNotPaused returns (bool) {
        console.log("Paused?", paused());
        require(!paused(), "paused");

        _approve(msg.sender, spender, value);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public  override whenNotPaused returns (bool) {
        require(!paused(), "paused");
        return super.transferFrom(sender, recipient, amount);
    }
    
    function transfer(address recipient, uint256 amount) public whenNotPaused override whenNotPaused returns (bool) {
        require(!paused(), "paused");
        return super.transfer(recipient, amount);
    }
}

//==============================================================================================

contract BadgerCoinTest is Test {

    BadgerCoin public badgerCoin;
    address public bob;
    address public alice;
    uint public supply = 1000000 * 10 ** 18;
    uint public decimal = 10 ** 18;

    function setUp() public {
        badgerCoin = new BadgerCoin();
        bob = vm.addr(1);
        alice = vm.addr(2);
        vm.deal(bob, 2 ether);
        vm.deal(alice, 2 ether);
    }

    function testTotalSupply() public {
        assertEq(badgerCoin.totalSupply(), supply);
    }

    function testDecimal() public {
        assertEq(badgerCoin.decimals(), 18);
    }

    function testBalanceOf() public {
        assertEq(badgerCoin.balanceOf(address(this)), supply);
    }

    function testTransfer() public {
        console.log("Player alice",badgerCoin.balanceOf(alice)/decimal);
        badgerCoin.transfer(alice, 1 ether);
        console.log("Player alice",badgerCoin.balanceOf(alice)/decimal);

    }

    function testTransferFail() public {
        console.log("Player alice",badgerCoin.balanceOf(alice)/decimal);
        console.log("Player bob",badgerCoin.balanceOf(bob)/decimal);

        vm.expectRevert("ERC20: transfer amount exceeds balance");
        
        vm.prank(alice);
        badgerCoin.transfer(bob, 1 ether);
        console.log("Player alice",badgerCoin.balanceOf(alice)/decimal);
        console.log("Player bob",badgerCoin.balanceOf(bob)/decimal);

    }

    function testMint() public {
        badgerCoin.mint(alice, 100);
        assertEq(badgerCoin.balanceOf(alice), 100);
    }

    function testApprove() public {
        badgerCoin.approve(alice, 100);
        assertEq(badgerCoin.allowance(address(this), alice), 100);
    }

     function testTransferFrom() public {
        console.log("Player alice", badgerCoin.balanceOf(alice) / decimal);

        badgerCoin.approve(alice, 1 ether);
        console.log("Player alice allowance", badgerCoin.allowance(address(this), alice));

        vm.prank(alice);
        badgerCoin.transferFrom(address(this), alice, 1 ether);

        console.log("Player alice", badgerCoin.balanceOf(alice) / decimal);
        console.log("Player bob", badgerCoin.balanceOf(bob) / decimal);
    }

      function testTransferFrom2() public {
        badgerCoin.approve(alice, 100);

        vm.prank(alice);
        badgerCoin.transferFrom(address(this), bob, 50);
        
        assertEq (badgerCoin.balanceOf(bob) , 50);

        assertEq (badgerCoin.allowance(address(this), alice), 50);
    }

    function testInsuficientAllowance() public {

        console.log("Player alice", badgerCoin.balanceOf(alice) / decimal);

        badgerCoin.approve(alice, 1 ether);
        console.log("Player alice allowance", badgerCoin.allowance(address(this), alice));
        vm.expectRevert("ERC20: insufficient allowance");

        vm.prank(alice);
        badgerCoin.transferFrom(address(this), alice, 10 ether);

        console.log("Player alice", badgerCoin.balanceOf(alice) / decimal);
        console.log("Player bob", badgerCoin.balanceOf(bob) / decimal);
    }

     function testUintMax() public {

        console.log("Player alice", badgerCoin.balanceOf(alice) / decimal);

        badgerCoin.approve(alice, 1 ether);
        console.log("Player alice allowance", badgerCoin.allowance(address(this), alice));
        vm.expectRevert("Arithmetic over/underflow");

        vm.prank(alice);
        badgerCoin.transferFrom(address(this), alice, type(uint).max +1);

        console.log("Player alice", badgerCoin.balanceOf(alice) / decimal);
        console.log("Player bob", badgerCoin.balanceOf(bob) / decimal);
    }

    function test_RevertWhen_OwnerZeroAddress() external {
        // Make the zero address the caller in this test.
        changePrank(address(0));

        // Run the test.
        vm.expectRevert("ERC20: approve from the zero address");
        badgerCoin.approve(alice, 1 ether );
    }

    function test_RevertWhen_SenderZeroAddress() external {
        // Make the zero address the caller in this test.
        changePrank(address(0));

        // Run the test.
        vm.expectRevert("ERC20: transfer from the zero address");
        badgerCoin.transfer(alice, 1 ether );
    }



       function test_BalanceOf_DoesNotHaveBalance(address foo) external {
        uint256 actualBalance = badgerCoin.balanceOf(foo);
        uint256 expectedBalance = 0;
        assertEq(actualBalance, expectedBalance, "balance");
    }

    function checkAssumptions(address owner, address to, uint256 amount0) internal pure {
        vm.assume(owner != address(0) && to != address(0));
        vm.assume(owner != to);
        vm.assume(amount0 > 0);
    }
}

```


## Test

```js
Running 14 tests for test/badgerupdater.sol:BadgerCoinTest
[PASS] testApprove() (gas: 39271)
Logs:
  Paused? false

Traces:
  [39271] BadgerCoinTest::testApprove() 
    ├─ [30359] BadgerCoin::approve(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 100) 
    │   ├─ [0] console::log(Paused?, false) [staticcall]
    │   │   └─ ← ()
    │   ├─ emit Approval(owner: BadgerCoinTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], spender: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, value: 100)
    │   └─ ← true
    ├─ [826] BadgerCoin::allowance(BadgerCoinTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 100
    └─ ← ()

[PASS] testBalanceOf() (gas: 9898)
Traces:
  [9898] BadgerCoinTest::testBalanceOf() 
    ├─ [2607] BadgerCoin::balanceOf(BadgerCoinTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496]) [staticcall]
    │   └─ ← 1000000000000000000000000
    └─ ← ()

[PASS] testDecimal() (gas: 5592)
Traces:
  [5592] BadgerCoinTest::testDecimal() 
    ├─ [266] BadgerCoin::decimals() [staticcall]
    │   └─ ← 18
    └─ ← ()

[PASS] testInsuficientAllowance() (gas: 59717)
Logs:
  Player alice 0
  Paused? false
  Player alice allowance 1000000000000000000
  Player alice 0
  Player bob 0

Traces:
  [59717] BadgerCoinTest::testInsuficientAllowance() 
    ├─ [2607] BadgerCoin::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c506c6179657220616c6963650000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [27859] BadgerCoin::approve(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 1000000000000000000) 
    │   ├─ [0] console::log(Paused?, false) [staticcall]
    │   │   └─ ← ()
    │   ├─ emit Approval(owner: BadgerCoinTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], spender: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, value: 1000000000000000000)
    │   └─ ← true
    ├─ [826] BadgerCoin::allowance(BadgerCoinTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 1000000000000000000
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000de0b6b3a76400000000000000000000000000000000000000000000000000000000000000000016506c6179657220616c69636520616c6c6f77616e636500000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [0] VM::expectRevert(ERC20: insufficient allowance) 
    │   └─ ← ()
    ├─ [0] VM::prank(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) 
    │   └─ ← ()
    ├─ [1396] BadgerCoin::transferFrom(BadgerCoinTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 10000000000000000000) 
    │   └─ ← "ERC20: insufficient allowance"
    ├─ [607] BadgerCoin::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c506c6179657220616c6963650000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [2607] BadgerCoin::balanceOf(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a506c6179657220626f6200000000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    └─ ← ()

[PASS] testMint() (gas: 40304)
Traces:
  [40304] BadgerCoinTest::testMint() 
    ├─ [31728] BadgerCoin::mint(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 100) 
    │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, value: 100)
    │   └─ ← ()
    ├─ [607] BadgerCoin::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 100
    └─ ← ()

[PASS] testTotalSupply() (gas: 9689)
Traces:
  [9689] BadgerCoinTest::testTotalSupply() 
    ├─ [2326] BadgerCoin::totalSupply() [staticcall]
    │   └─ ← 1000000000000000000000000
    └─ ← ()

[PASS] testTransfer() (gas: 48472)
Logs:
  Player alice 0
  Player alice 1

Traces:
  [48472] BadgerCoinTest::testTransfer() 
    ├─ [2607] BadgerCoin::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c506c6179657220616c6963650000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [30433] BadgerCoin::transfer(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 1000000000000000000) 
    │   ├─ emit Transfer(from: BadgerCoinTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], to: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, value: 1000000000000000000)
    │   └─ ← true
    ├─ [607] BadgerCoin::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 1000000000000000000
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000c506c6179657220616c6963650000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    └─ ← ()

[PASS] testTransferFail() (gas: 33121)
Logs:
  Player alice 0
  Player bob 0
  Player alice 0
  Player bob 0

Traces:
  [33121] BadgerCoinTest::testTransferFail() 
    ├─ [2607] BadgerCoin::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c506c6179657220616c6963650000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [2607] BadgerCoin::balanceOf(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a506c6179657220626f6200000000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [0] VM::expectRevert(ERC20: transfer amount exceeds balance) 
    │   └─ ← ()
    ├─ [0] VM::prank(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) 
    │   └─ ← ()
    ├─ [3438] BadgerCoin::transfer(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf, 1000000000000000000) 
    │   └─ ← "ERC20: transfer amount exceeds balance"
    ├─ [607] BadgerCoin::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c506c6179657220616c6963650000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [607] BadgerCoin::balanceOf(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a506c6179657220626f6200000000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    └─ ← ()

[PASS] testTransferFrom() (gas: 68928)
Logs:
  Player alice 0
  Paused? false
  Player alice allowance 1000000000000000000
  Player alice 1
  Player bob 0

Traces:
  [71063] BadgerCoinTest::testTransferFrom() 
    ├─ [2607] BadgerCoin::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c506c6179657220616c6963650000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [27859] BadgerCoin::approve(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 1000000000000000000) 
    │   ├─ [0] console::log(Paused?, false) [staticcall]
    │   │   └─ ← ()
    │   ├─ emit Approval(owner: BadgerCoinTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], spender: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, value: 1000000000000000000)
    │   └─ ← true
    ├─ [826] BadgerCoin::allowance(BadgerCoinTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 1000000000000000000
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000de0b6b3a76400000000000000000000000000000000000000000000000000000000000000000016506c6179657220616c69636520616c6c6f77616e636500000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [0] VM::prank(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) 
    │   └─ ← ()
    ├─ [24759] BadgerCoin::transferFrom(BadgerCoinTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 1000000000000000000) 
    │   ├─ emit Approval(owner: BadgerCoinTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], spender: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, value: 0)
    │   ├─ emit Transfer(from: BadgerCoinTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], to: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, value: 1000000000000000000)
    │   └─ ← true
    ├─ [607] BadgerCoin::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 1000000000000000000
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000c506c6179657220616c6963650000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [2607] BadgerCoin::balanceOf(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a506c6179657220626f6200000000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    └─ ← ()

[PASS] testTransferFrom2() (gas: 79174)
Logs:
  Paused? false

Traces:
  [79174] BadgerCoinTest::testTransferFrom2() 
    ├─ [30359] BadgerCoin::approve(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 100) 
    │   ├─ [0] console::log(Paused?, false) [staticcall]
    │   │   └─ ← ()
    │   ├─ emit Approval(owner: BadgerCoinTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], spender: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, value: 100)
    │   └─ ← true
    ├─ [0] VM::prank(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) 
    │   └─ ← ()
    ├─ [32948] BadgerCoin::transferFrom(BadgerCoinTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf, 50) 
    │   ├─ emit Approval(owner: BadgerCoinTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], spender: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, value: 50)
    │   ├─ emit Transfer(from: BadgerCoinTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], to: 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf, value: 50)
    │   └─ ← true
    ├─ [607] BadgerCoin::balanceOf(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) [staticcall]
    │   └─ ← 50
    ├─ [826] BadgerCoin::allowance(BadgerCoinTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 50
    └─ ← ()

[FAIL. Reason: Error != expected error: NH{q != Arithmetic over/underflow] testUintMax() (gas: 49686)
Logs:
  Player alice 0
  Paused? false
  Player alice allowance 1000000000000000000

Traces:
  [802583] BadgerCoinTest::setUp() 
    ├─ [698429] → new BadgerCoin@0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f
    │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: BadgerCoinTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], value: 1000000000000000000000000)
    │   └─ ← 2919 bytes of code
    ├─ [0] VM::addr(<pk>) [staticcall]
    │   └─ ← 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf
    ├─ [0] VM::addr(<pk>) [staticcall]
    │   └─ ← 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF
    ├─ [0] VM::deal(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf, 2000000000000000000) 
    │   └─ ← ()
    ├─ [0] VM::deal(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 2000000000000000000) 
    │   └─ ← ()
    └─ ← ()

  [49686] BadgerCoinTest::testUintMax() 
    ├─ [2607] BadgerCoin::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c506c6179657220616c6963650000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [27859] BadgerCoin::approve(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 1000000000000000000) 
    │   ├─ [0] console::log(Paused?, false) [staticcall]
    │   │   └─ ← ()
    │   ├─ emit Approval(owner: BadgerCoinTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], spender: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, value: 1000000000000000000)
    │   └─ ← true
    ├─ [826] BadgerCoin::allowance(BadgerCoinTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 1000000000000000000
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000de0b6b3a76400000000000000000000000000000000000000000000000000000000000000000016506c6179657220616c69636520616c6c6f77616e636500000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [0] VM::expectRevert(Arithmetic over/underflow) 
    │   └─ ← ()
    ├─ [0] VM::prank(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) 
    │   └─ ← ()
    └─ ← "Arithmetic over/underflow"

[PASS] test_BalanceOf_DoesNotHaveBalance(address) (runs: 256, μ: 8039, ~: 8039)
Traces:
  [8039] BadgerCoinTest::test_BalanceOf_DoesNotHaveBalance(0x82721844D5C8b05f3814F0FC275F13D05ae8a92F) 
    ├─ [2607] BadgerCoin::balanceOf(0x82721844D5C8b05f3814F0FC275F13D05ae8a92F) [staticcall]
    │   └─ ← 0
    └─ ← ()

[PASS] test_RevertWhen_OwnerZeroAddress() (gas: 17371)
Logs:
  Paused? false

Traces:
  [17371] BadgerCoinTest::test_RevertWhen_OwnerZeroAddress() 
    ├─ [0] VM::stopPrank() 
    │   └─ ← ()
    ├─ [0] VM::startPrank(0x0000000000000000000000000000000000000000) 
    │   └─ ← ()
    ├─ [0] VM::expectRevert(Custom Error 45524332:(0x726f6d20746865207a65726F2061646472657373)) 
    │   └─ ← ()
    ├─ [6274] BadgerCoin::approve(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 1000000000000000000) 
    │   ├─ [0] console::log(Paused?, false) [staticcall]
    │   │   └─ ← ()
    │   └─ ← "ERC20: approve from the zero address"
    └─ ← ()

[PASS] test_RevertWhen_SenderZeroAddress() (gas: 14281)
Traces:
  [14281] BadgerCoinTest::test_RevertWhen_SenderZeroAddress() 
    ├─ [0] VM::stopPrank() 
    │   └─ ← ()
    ├─ [0] VM::startPrank(0x0000000000000000000000000000000000000000) 
    │   └─ ← ()
    ├─ [0] VM::expectRevert(ERC20: transfer from the zero address) 
    │   └─ ← ()
    ├─ [3184] BadgerCoin::transfer(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 1000000000000000000) 
    │   └─ ← "ERC20: transfer from the zero address"
    └─ ← ()

Test result: FAILED. 13 passed; 1 failed; finished in 7.56ms

Failing tests:
Encountered 1 failing test in test/badgerupdater.sol:BadgerCoinTest
[FAIL. Reason: Error != expected error: NH{q != Arithmetic over/underflow] testUintMax() (gas: 49686)

Encountered a total of 1 failing tests, 13 tests succeeded

```