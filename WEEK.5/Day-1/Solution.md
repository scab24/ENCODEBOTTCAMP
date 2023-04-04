
# Homework 16

- Code
- Debugger

## Code

```js
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "lib/forge-std/src/Test.sol";
import "./Interfacesp.sol";


contract ContractTest is Test {

  //Contract Factory
  IPancakeFactory constant factory = IPancakeFactory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
  //Contract Router
  IPancakeRouter02 constant router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
  //par cake / USDT => https://pancakeswap.finance/info/pairs/0xa39af17ce4a8eb807e076805da1e2b8ea7d0755b
  IPancakePair constant parCakeUSDT = IPancakePair(0xA39Af17CE4a8eb807E076805Da1e2B8EA7D0755b);
  //USDT / LEGO => 
  IPancakePair constant parUsdtLego = IPancakePair(0x94a34ADdFe427170f895764737d8bA7a2E7aC405);
  // LEGO/BUSD
  IPancakePair constant parLegoBusd = IPancakePair(0xb95817627a289EDB10C4fe6a126f41665Eb6B8B9);
    //LEGO
    address Lego = 0x520EbCcc63E4d0804b35Cda25978BEb7159bF0CC;
    address Busd = 0x55d398326f99059fF775485246999027B3197955;

//Address exercise
  address homework = 0xffefE959d8bAEA028b1697ABfc4285028d6CEB10;




  function setUp() public {
    vm.createSelectFork("bsc");  
  }


  function testFactory() public  {
    console.log("allPairsLength",factory.allPairsLength());
    console.log("allPairs",factory.allPairs(1));
    console.log("feeToSetter",factory.feeToSetter());
    console.log("getPair LEGO/BUSD",factory.getPair(Lego,Busd));
    assertEq(factory.getPair(Lego,Busd),0xb95817627a289EDB10C4fe6a126f41665Eb6B8B9);

  }


  function testgetReservesLegoBusdt() public {
    console.log("WETH",router.WETH());
    console.log("factory",router.factory());
    assertEq(router.factory(),0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
  }
  

  event LogReserves(uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function testgetReservesCakeUsdt() public {
    console.log("name", parLegoBusd.name());
    console.log("TotalSupply",parLegoBusd.totalSupply());
    //"Reserve cake/USDT"
    (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = parLegoBusd.getReserves();
    emit LogReserves(reserve0, reserve1, blockTimestampLast);
    //Balance address
    console.log("Balance addressExercise", parLegoBusd.balanceOf(homework));
  }


  function testObtenerLEGO() public {
     vm.startPrank(homework);
     parLegoBusd.transfer(address(this), 1);
  }


}

```

## Debug

```js
Running 4 tests for test/defi.sol:ContractTest
[PASS] testFactory() (gas: 25389)
Logs:
  allPairsLength 1282622
  allPairs 0x0eD7e52944161450477ee417DE9Cd3a859b14fD0
  feeToSetter 0xcEba60280fb0ecd9A5A26A1552B90944770a4a0e
  getPair LEGO/BUSD 0xb95817627a289EDB10C4fe6a126f41665Eb6B8B9

Traces:
  [25389] ContractTest::testFactory() 
    ├─ [2388] 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73::allPairsLength() [staticcall]
    │   └─ ← 0x000000000000000000000000000000000000000000000000000000000013923e
    ├─ [0] console::9710a9d0(0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000013923e000000000000000000000000000000000000000000000000000000000000000e616c6c50616972734c656e677468000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [2662] 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73::allPairs(1) [staticcall]
    │   └─ ← 0x0000000000000000000000000ed7e52944161450477ee417de9cd3a859b14fd0
    ├─ [0] console::log(allPairs, 0x0eD7e52944161450477ee417DE9Cd3a859b14fD0) [staticcall]
    │   └─ ← ()
    ├─ [2376] 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73::feeToSetter() [staticcall]
    │   └─ ← 0x000000000000000000000000ceba60280fb0ecd9a5a26a1552b90944770a4a0e
    ├─ [0] console::log(feeToSetter, 0xcEba60280fb0ecd9A5A26A1552B90944770a4a0e) [staticcall]
    │   └─ ← ()
    ├─ [2676] 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73::getPair(0x520EbCcc63E4d0804b35Cda25978BEb7159bF0CC, 0x55d398326f99059fF775485246999027B3197955) [staticcall]
    │   └─ ← 0x000000000000000000000000b95817627a289edb10c4fe6a126f41665eb6b8b9
    ├─ [0] console::log(getPair LEGO/BUSD, 0xb95817627a289EDB10C4fe6a126f41665Eb6B8B9) [staticcall]
    │   └─ ← ()
    ├─ [676] 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73::getPair(0x520EbCcc63E4d0804b35Cda25978BEb7159bF0CC, 0x55d398326f99059fF775485246999027B3197955) [staticcall]
    │   └─ ← 0x000000000000000000000000b95817627a289edb10c4fe6a126f41665eb6b8b9
    └─ ← ()

[PASS] testObtenerLEGO() (gas: 5141)
Traces:
  [5141] ContractTest::testObtenerLEGO() 
    ├─ [0] VM::startPrank(0xffefE959d8bAEA028b1697ABfc4285028d6CEB10) 
    │   └─ ← ()
    └─ ← ()

[PASS] testRouter() (gas: 8714)
Logs:
  WETH 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
  factory 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73

Traces:
  [8714] ContractTest::testRouter() 
    ├─ [275] 0x10ED43C718714eb63d5aA57B78B54704E256024E::WETH() [staticcall]
    │   └─ ← 0x000000000000000000000000bb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c
    ├─ [0] console::log(WETH, 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c) [staticcall]
    │   └─ ← ()
    ├─ [252] 0x10ED43C718714eb63d5aA57B78B54704E256024E::factory() [staticcall]
    │   └─ ← 0x000000000000000000000000ca143ce32fe78f1f7019d7d551a6402fc5350c73
    ├─ [0] console::log(factory, 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73) [staticcall]
    │   └─ ← ()
    ├─ [252] 0x10ED43C718714eb63d5aA57B78B54704E256024E::factory() [staticcall]
    │   └─ ← 0x000000000000000000000000ca143ce32fe78f1f7019d7d551a6402fc5350c73
    └─ ← ()

[PASS] testgetReservesLegoBusdt() (gas: 22000)
Logs:
  name Pancake LPs
  TotalSupply 199160658094583841
  Balance addressExercise 0

Traces:
  [22000] ContractTest::testgetReservesLegoBusdt() 
    ├─ [651] 0xb95817627a289EDB10C4fe6a126f41665Eb6B8B9::name() [staticcall]
    │   └─ ← 0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000b50616e63616b65204c5073000000000000000000000000000000000000000000
    ├─ [0] console::log(name, Pancake LPs) [staticcall]
    │   └─ ← ()
    ├─ [2439] 0xb95817627a289EDB10C4fe6a126f41665Eb6B8B9::totalSupply() [staticcall]
    │   └─ ← 0x00000000000000000000000000000000000000000000000002c38f9036f5f021
    ├─ [0] console::9710a9d0(000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000002c38f9036f5f021000000000000000000000000000000000000000000000000000000000000000b546f74616c537570706c79000000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [2893] 0xb95817627a289EDB10C4fe6a126f41665Eb6B8B9::getReserves() [staticcall]
    │   └─ ← 0x00000000000000000000000000000000000000000000000000002a11dcafd002000000000000000000000000000000000000000000000038a899090486082d7d00000000000000000000000000000000000000000000000000000000642c2990
    ├─ emit LogReserves(reserve0: 46256205320194, reserve1: 1045166419512576716157, blockTimestampLast: 1680615824)
    ├─ [2537] 0xb95817627a289EDB10C4fe6a126f41665Eb6B8B9::balanceOf(0xffefE959d8bAEA028b1697ABfc4285028d6CEB10) [staticcall]
    │   └─ ← 0x0000000000000000000000000000000000000000000000000000000000000000
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001742616c616e636520616464726573734578657263697365000000000000000000) [staticcall]
    │   └─ ← ()
    └─ ← ()

Test result: ok. 4 passed; 0 failed; finished in 1.79s
```