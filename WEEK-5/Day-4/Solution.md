# Homework 19



## Code

```js
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

import "lib/forge-std/src/Test.sol";


contract ShameCoin {
    string public name = "Shame Coin";
    string public symbol = "SHAME";
    uint256 public decimals;
    uint256 public totalSupply;
    address public admin;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public authorized;


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        admin = msg.sender;
        totalSupply = 0;
        decimals = 0;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    function assignInitialBalance(address account, uint256 amount) external onlyAdmin {
        balanceOf[account] = amount;
        totalSupply += amount;
        emit Transfer(address(0), account, amount);
    }

    function transfer(address to) public payable returns (bool success) {
        require (msg.sender != address(0), "No address 0");

        if (msg.sender == admin) {
            require(balanceOf[msg.sender] >= 1, "Insufficient balance");
            balanceOf[msg.sender] -= 1;
            balanceOf[to] += 1;
            emit Transfer(msg.sender, to, 1);
            return true;
        } else {
            // require(msg.value == 1, "Incorrect value");
            balanceOf[msg.sender] += 1;
            emit Transfer(address(0), msg.sender, 1);
            return false;
        }
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        require (msg.sender != address(0), "No address 0");
        require(msg.sender != admin, "Admin cannot approve themselves");
        require(!authorized[msg.sender], "Already authorized");
        require (value == 1, "Incorrect value");

        authorized[msg.sender] = true;

        allowance[msg.sender][spender] += value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require (msg.sender != address(0), "No address 0");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Not authorized to spend this much");

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
}


contract ContractTestShameCoin is Test {

    ShameCoin shameCoin;
    address bob = vm.addr(1);
    address alice = vm.addr(2);
    address carlos = vm.addr(3);

    function setUp() public {
        vm.deal(bob, 1000 ether);
        vm.deal(alice, 1000 ether);

        vm.startPrank(bob);
        shameCoin = new ShameCoin();

        shameCoin.assignInitialBalance(bob, 10 ether);
        shameCoin.assignInitialBalance(alice, 10 ether);
        vm.stopPrank();

    }


    function testinstante() public {

        console.log("TotalSupply",shameCoin.totalSupply());
        console.log("decimal",shameCoin.decimals());
        console.log("admin", shameCoin.admin());
        uint256 balanceBob = shameCoin.balanceOf(bob);
        uint256 balanceAlice = shameCoin.balanceOf(alice);

        assertEq(shameCoin.totalSupply(),balanceBob + balanceAlice );
        assertEq(shameCoin.decimals(), 0);
        assertEq(shameCoin.admin(), bob);

    }

//========================================
            //TRANSFER
//========================================
    function testbalanceAdmin() public {
        //verifico que envio 1 con admin
        // console.log("BalanceOf bob before",shameCoin.balanceOf(bob));
        // console.log("BalanceOf alice before",shameCoin.balanceOf(alice));

        uint256 balanceBeforeBob = shameCoin.balanceOf(bob);
        uint256 balanceBeforeAlice = shameCoin.balanceOf(alice);

        vm.prank(bob);
        shameCoin.transfer{value: 1 ether}(alice);
        uint256 balanceAfterBob = shameCoin.balanceOf(bob);
        uint256 balanceAfterAlcie = shameCoin.balanceOf(alice);

        assertEq(balanceAfterBob,balanceBeforeBob - 1 );
        assertEq(balanceAfterAlcie,balanceBeforeAlice + 1 );

        // console.log("BalanceOf bob after",shameCoin.balanceOf(bob));
        // console.log("BalanceOf alice after",shameCoin.balanceOf(alice));

    }

    function testbalanceNOAdmin() public {
        //verify that I send 1 with !admin
        //increment +1 the value of msg.sender;

        uint256 balanceBeforeBob = shameCoin.balanceOf(bob);
        uint256 balanceBeforeAlice = shameCoin.balanceOf(alice);

        vm.prank(alice);
        shameCoin.transfer{value: 1 ether}(bob);
        uint256 balanceAfterBob = shameCoin.balanceOf(bob);
        uint256 balanceAfterAlcie = shameCoin.balanceOf(alice);

        assertEq(balanceAfterBob,balanceBeforeBob);
        assertEq(balanceAfterAlcie,balanceBeforeAlice + 1 );
    }

//========================================
            //APPROVE
//========================================

//call admin
    function testapproveAdmin () public {
        vm.prank(bob);
        vm.expectRevert("Admin cannot approve themselves");
        shameCoin.approve(alice, 10);
    }

// call !admin != value
    function testapproveNOAdmin () public {
        vm.prank(alice);
        vm.expectRevert("Incorrect value");
        shameCoin.approve(alice, 10);
    }

// Good performance 
    function testapproveNOAdminYes () public {
        uint256 AlicetoBobBefore = shameCoin.allowance(alice, bob);
        console.log("allowance",AlicetoBobBefore );

        vm.prank(alice);
        shameCoin.approve(bob, 1);

        uint256 AlicetoBobAfter = shameCoin.allowance(alice, bob);

        assertEq(AlicetoBobAfter,AlicetoBobBefore + 1 );
        console.log("allowanceAfter",AlicetoBobAfter);
    }

    // " and verify that !=admin cannot send >1 
    function testapproveNOAdminx2 () public {

        uint256 AlicetoBobBefore = shameCoin.allowance(alice, bob);
        console.log("allowance",AlicetoBobBefore );

        // first call allowed
        vm.prank(alice);
        shameCoin.approve(bob, 1);

        uint256 AlicetoBobAfter = shameCoin.allowance(alice, bob);
        console.log("allowanceAfter",AlicetoBobAfter);

        assertEq(AlicetoBobAfter,AlicetoBobBefore + 1 );

        // second call not allowed

        vm.expectRevert("Already authorized");
        vm.prank(alice);
        shameCoin.approve(bob, 1);

        uint256 AlicetoBobAfter2 = shameCoin.allowance(alice, bob);
        console.log("allowanceAfter",AlicetoBobAfter2);
    }

//========================================
            //TRANSFERFROM
//========================================

    function testTransferFrom () public {
        //Allowance Before
        uint256 AlicetoCarlosBefore = shameCoin.allowance(alice, carlos);
        console.log("allowance",AlicetoCarlosBefore );
        //Balance Before
        uint256 BalanceAliceBefore = shameCoin.balanceOf(alice);
        console.log("BalanceOf Alice",BalanceAliceBefore );

        //call approve
        vm.prank(alice);
        shameCoin.approve(carlos, 1);

        //verify approve
        uint256 AlicetoCarlosAfter = shameCoin.allowance(alice, carlos);
        assertEq(AlicetoCarlosAfter,AlicetoCarlosBefore + 1 );
        console.log("allowanceAfter",AlicetoCarlosAfter);

        //call TransferFrom
        vm.prank(carlos);
        shameCoin.transferFrom(alice, carlos, 1);

        //verify allowance
        uint256 AliceCarlosAfter2 = shameCoin.allowance(alice, carlos);
        assertEq(AliceCarlosAfter2, AlicetoCarlosAfter -1 );
        console.log("allowanceAfter2",AliceCarlosAfter2);

        //verify BalanceOf after TransferFrom
        uint256 BalanceAliceAfter = shameCoin.balanceOf(alice);
        assertEq(BalanceAliceAfter,BalanceAliceBefore -1 );
        console.log("BalanceOf Alice",BalanceAliceAfter );
    }

 
}

```


## Debug

```js
forge test --match-contract ContractTestShameCoin -vvvv           
[⠘] Compiling...
No files changed, compilation skipped

Running 8 tests for test/ShameCoin.sol:ContractTestShameCoin
[PASS] testTransferFrom() (gas: 88850)
Logs:
  allowance 0
  BalanceOf Alice 10000000000000000000
  allowanceAfter 1
  allowanceAfter2 0
  BalanceOf Alice 9999999999999999999

Traces:
  [88850] ContractTestShameCoin::testTransferFrom() 
    ├─ [2814] ShameCoin::allowance(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009616c6c6f77616e63650000000000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [2552] ShameCoin::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 10000000000000000000
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000008ac7230489e80000000000000000000000000000000000000000000000000000000000000000000f42616c616e63654f6620416c6963650000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [0] VM::prank(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) 
    │   └─ ← ()
    ├─ [47224] ShameCoin::approve(0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69, 1) 
    │   ├─ emit Approval(owner: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, spender: 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69, value: 1)
    │   └─ ← true
    ├─ [814] ShameCoin::allowance(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69) [staticcall]
    │   └─ ← 1
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000e616c6c6f77616e63654166746572000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [0] VM::prank(0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69) 
    │   └─ ← ()
    ├─ [23172] ShameCoin::transferFrom(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69, 1) 
    │   ├─ emit Transfer(from: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, to: 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69, value: 1)
    │   └─ ← true
    ├─ [814] ShameCoin::allowance(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f616c6c6f77616e63654166746572320000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [552] ShameCoin::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 9999999999999999999
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000008ac7230489e7ffff000000000000000000000000000000000000000000000000000000000000000f42616c616e63654f6620416c6963650000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    └─ ← ()

[PASS] testapproveAdmin() (gas: 15649)
Traces:
  [15649] ContractTestShameCoin::testapproveAdmin() 
    ├─ [0] VM::prank(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) 
    │   └─ ← ()
    ├─ [0] VM::expectRevert(Admin cannot approve themselves) 
    │   └─ ← ()
    ├─ [2636] ShameCoin::approve(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 10) 
    │   └─ ← "Admin cannot approve themselves"
    └─ ← ()

[PASS] testapproveNOAdmin() (gas: 15944)
Traces:
  [15944] ContractTestShameCoin::testapproveNOAdmin() 
    ├─ [0] VM::prank(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) 
    │   └─ ← ()
    ├─ [0] VM::expectRevert(Incorrect value) 
    │   └─ ← ()
    ├─ [4859] ShameCoin::approve(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 10) 
    │   └─ ← "Incorrect value"
    └─ ← ()

[PASS] testapproveNOAdminYes() (gas: 69384)
Logs:
  allowance 0
  allowanceAfter 1

Traces:
  [69384] ContractTestShameCoin::testapproveNOAdminYes() 
    ├─ [2814] ShameCoin::allowance(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009616c6c6f77616e63650000000000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [0] VM::prank(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) 
    │   └─ ← ()
    ├─ [47224] ShameCoin::approve(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf, 1) 
    │   ├─ emit Approval(owner: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, spender: 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf, value: 1)
    │   └─ ← true
    ├─ [814] ShameCoin::allowance(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) [staticcall]
    │   └─ ← 1
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000e616c6c6f77616e63654166746572000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    └─ ← ()

[PASS] testapproveNOAdminx2() (gas: 74483)
Logs:
  allowance 0
  allowanceAfter 1
  allowanceAfter 1

Traces:
  [74483] ContractTestShameCoin::testapproveNOAdminx2() 
    ├─ [2814] ShameCoin::allowance(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009616c6c6f77616e63650000000000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [0] VM::prank(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) 
    │   └─ ← ()
    ├─ [47224] ShameCoin::approve(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf, 1) 
    │   ├─ emit Approval(owner: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, spender: 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf, value: 1)
    │   └─ ← true
    ├─ [814] ShameCoin::allowance(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) [staticcall]
    │   └─ ← 1
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000e616c6c6f77616e63654166746572000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [0] VM::expectRevert(Already authorized) 
    │   └─ ← ()
    ├─ [0] VM::prank(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) 
    │   └─ ← ()
    ├─ [836] ShameCoin::approve(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf, 1) 
    │   └─ ← "Already authorized"
    ├─ [814] ShameCoin::allowance(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) [staticcall]
    │   └─ ← 1
    ├─ [0] console::9710a9d0(00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000e616c6c6f77616e63654166746572000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    └─ ← ()

[PASS] testbalanceAdmin() (gas: 39929)
Traces:
  [39929] ContractTestShameCoin::testbalanceAdmin() 
    ├─ [2552] ShameCoin::balanceOf(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) [staticcall]
    │   └─ ← 10000000000000000000
    ├─ [2552] ShameCoin::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 10000000000000000000
    ├─ [0] VM::prank(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) 
    │   └─ ← ()
    ├─ [11056] ShameCoin::transfer{value: 1000000000000000000}(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) 
    │   ├─ emit Transfer(from: 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf, to: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, value: 1)
    │   └─ ← true
    ├─ [552] ShameCoin::balanceOf(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) [staticcall]
    │   └─ ← 9999999999999999999
    ├─ [552] ShameCoin::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 10000000000000000001
    └─ ← ()

[PASS] testbalanceNOAdmin() (gas: 36394)
Traces:
  [36394] ContractTestShameCoin::testbalanceNOAdmin() 
    ├─ [2552] ShameCoin::balanceOf(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) [staticcall]
    │   └─ ← 10000000000000000000
    ├─ [2552] ShameCoin::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 10000000000000000000
    ├─ [0] VM::prank(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) 
    │   └─ ← ()
    ├─ [7652] ShameCoin::transfer{value: 1000000000000000000}(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) 
    │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, value: 1)
    │   └─ ← false
    ├─ [552] ShameCoin::balanceOf(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) [staticcall]
    │   └─ ← 10000000000000000000
    ├─ [552] ShameCoin::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 10000000000000000001
    └─ ← ()

[PASS] testinstante() (gas: 32806)
Logs:
  TotalSupply 20000000000000000000
  decimal 0
  admin 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf

Traces:
  [32806] ContractTestShameCoin::testinstante() 
    ├─ [2373] ShameCoin::totalSupply() [staticcall]
    │   └─ ← 20000000000000000000
    ├─ [0] console::9710a9d0(0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000001158e460913d00000000000000000000000000000000000000000000000000000000000000000000b546f74616c537570706c79000000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [2439] ShameCoin::decimals() [staticcall]
    │   └─ ← 0
    ├─ [0] console::9710a9d0(000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007646563696d616c00000000000000000000000000000000000000000000000000) [staticcall]
    │   └─ ← ()
    ├─ [2480] ShameCoin::admin() [staticcall]
    │   └─ ← 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf
    ├─ [0] console::log(admin, 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) [staticcall]
    │   └─ ← ()
    ├─ [2552] ShameCoin::balanceOf(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) [staticcall]
    │   └─ ← 10000000000000000000
    ├─ [2552] ShameCoin::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 10000000000000000000
    ├─ [373] ShameCoin::totalSupply() [staticcall]
    │   └─ ← 20000000000000000000
    ├─ [439] ShameCoin::decimals() [staticcall]
    │   └─ ← 0
    ├─ [480] ShameCoin::admin() [staticcall]
    │   └─ ← 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf
    └─ ← ()

Test result: ok. 8 passed; 0 failed; finished in 5.68ms
```