# Homwork 8


## Code for Badgercoin

```js
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/forge-std/src/Test.sol";


contract BadgerCoin is ERC20 {
    constructor() ERC20("BadgerCoin", "BC") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}

contract ContractTestBadger is Test {

    BadgerCoin badgercoin;
    address bob;
    address alice;
    uint supply = 1000000 * 10 ** 18;
    uint decimal = 10 ** 18;

    function setUp() public {
        badgercoin = new BadgerCoin();
        // vm.deal(address(badgercoin), 5 ether); 
        bob = vm.addr(1);
        alice = vm.addr(2);

        vm.deal(bob, 2 ether);
        vm.deal(alice, 2 ether);

    }

    function testTotalSupply() public {
        console.log("TotalSupply", badgercoin.totalSupply());
        assertEq(badgercoin.totalSupply(), supply);
    }

    function testDecimal() public {
        assertEq(badgercoin.decimals(), 18);
    }

    function testBalanceOf() public {
        console.log(badgercoin.balanceOf(address(this)));
        assertEq(badgercoin.balanceOf(address(this)),supply);
    }

    function testTransfer() public {
        console.log("Player alice",badgercoin.balanceOf(alice)/decimal);
        badgercoin.transfer(alice, 1 ether);
        console.log("Player alice",badgercoin.balanceOf(alice)/decimal);

    }

    function testTransferFail() public {
        console.log("Player alice",badgercoin.balanceOf(alice)/decimal);
        console.log("Player bob",badgercoin.balanceOf(bob)/decimal);

        vm.expectRevert("ERC20: transfer amount exceeds balance");
        
        vm.prank(alice);
        badgercoin.transfer(bob, 1 ether);
        console.log("Player alice",badgercoin.balanceOf(alice)/decimal);
        console.log("Player bob",badgercoin.balanceOf(bob)/decimal);

    } 
}

```

## Test Result

```js
Running 5 tests for test/badger.sol:ContractTestBadger
[PASS] testBalanceOf() (gas: 13718)
Logs:
  1000000000000000000000000

Traces:
  [13718] ContractTestBadger::testBalanceOf() 
    ├─ [2562] BadgerCoin::balanceOf(ContractTestBadger: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496]) [staticcall]
    │   └─ ← 1000000000000000000000000
    ├─ [0] console::f5b1bba9(00000000000000000000000000000000000000000000d3c21bcecceda1000000) [staticcall]
    │   └─ ← ()
    ├─ [562] BadgerCoin::balanceOf(ContractTestBadger: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496]) [staticcall]
    │   └─ ← 1000000000000000000000000
    └─ ← ()

[PASS] testDecimal() (gas: 5548)
Traces:
  [5548] ContractTestBadger::testDecimal() 
    ├─ [266] BadgerCoin::decimals() [staticcall]
    │   └─ ← 18
    └─ ← ()

[PASS] testTotalSupply() (gas: 13614)
Logs:
  TotalSupply 1000000000000000000000000

Traces:
  [13614] ContractTestBadger::testTotalSupply() 
    ├─ [2326] BadgerCoin::totalSupply() [staticcall]
    │   └─ ← 1000000000000000000000000
    ├─ [0] console::9710a9d0(000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000d3c21bcecceda1000000000000000000000000000000000000000000000000000000000000000000000b546f74616c537570706c79000000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [326] BadgerCoin::totalSupply() [staticcall]
    │   └─ ← 1000000000000000000000000
    └─ ← ()

[PASS] testTransfer() (gas: 45592)
Logs:
  Player alice 0
  Player alice 1

Traces:
  [45592] ContractTestBadger::testTransfer() 
    ├─ [2562] BadgerCoin::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c506c6179657220616c6963650000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [27838] BadgerCoin::transfer(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 1000000000000000000) 
    │   ├─ emit Transfer(from: ContractTestBadger: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], to: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, value: 1000000000000000000)
    │   └─ ← true
    ├─ [562] BadgerCoin::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 1000000000000000000
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000c506c6179657220616c6963650000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    └─ ← ()

[PASS] testTransferFail() (gas: 29989)
Logs:
  Player alice 0
  Player bob 0
  Player alice 0
  Player bob 0

Traces:
  [29989] ContractTestBadger::testTransferFail() 
    ├─ [2562] BadgerCoin::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c506c6179657220616c6963650000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [2562] BadgerCoin::balanceOf(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a506c6179657220626f6200000000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [0] VM::expectRevert(ERC20: transfer amount exceeds balance) 
    │   └─ ← ()
    ├─ [0] VM::prank(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) 
    │   └─ ← ()
    ├─ [860] BadgerCoin::transfer(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf, 1000000000000000000) 
    │   └─ ← "ERC20: transfer amount exceeds balance"
    ├─ [562] BadgerCoin::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c506c6179657220616c6963650000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [562] BadgerCoin::balanceOf(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a506c6179657220626f6200000000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    └─ ← ()

Test result: ok. 5 passed; 0 failed; finished in 5.40ms
```