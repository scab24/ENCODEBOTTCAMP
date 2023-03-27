# Homework 11

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

contract Vault {
    // slot 0
    uint256 private password;
    constructor(uint256  _password) {
        password = _password;
        User memory user = User({id: 0, password: bytes32(_password)});
        users.push(user);
        idToUser[0] = user;
    }

    struct User {
        uint id;
        bytes32 password;
    }

    // slot 1
    User[] public users;
    // slot 2
    mapping(uint => User) public idToUser; 
    function getArrayLocation(
        uint slot,
        uint index,
        uint elementSize
    ) public pure returns (bytes32) {
        uint256 a= uint(keccak256(abi.encodePacked(slot))) + (index * elementSize);
        return bytes32(a);
    }
}

contract ContractTest is Test {
        Vault VaultContract;

    function testReadprivatedata() public {
        VaultContract = new Vault(123456789);
        bytes32 leet = vm.load(address(VaultContract), bytes32(uint256(0)));
        emit log_uint(uint256(leet)); 

    // users in slot 1 - length of array
    // starting from slot hash(1) - array elements
    // slot where array element is stored = keccak256(slot)) + (index * elementSize)
    // where slot = 1 and elementSize = 2 (1 (uint) +  1 (bytes32))
        bytes32 user = vm.load(address(VaultContract), VaultContract.getArrayLocation(1,1,1));
        emit log_uint(uint256(user)); 
    }

}
```

## Test

```js
[PASS] testReadprivatedata() (gas: 253418)
Logs:
  123456789
  123456789

Traces:
  [253418] ContractTest::testReadprivatedata() 
    ├─ [192263] → new Vault@0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f
    │   └─ ← 495 bytes of code
    ├─ [0] VM::load(Vault: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 0x0000000000000000000000000000000000000000000000000000000000000000) 
    │   └─ ← 0x00000000000000000000000000000000000000000000000000000000075bcd15
    ├─ emit log_uint(: 123456789)
    ├─ [663] Vault::getArrayLocation(1, 1, 1) [staticcall]
    │   └─ ← 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf7
    ├─ [0] VM::load(Vault: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf7) 
    │   └─ ← 0x00000000000000000000000000000000000000000000000000000000075bcd15
    ├─ emit log_uint(: 123456789)
    └─ ← ()

```

## Gas report

```js
Test result: ok. 1 passed; 0 failed; finished in 3.59ms
| src/test/Privatedata.sol:Vault contract |                 |     |        |     |         |
|-----------------------------------------|-----------------|-----|--------|-----|---------|
| Deployment Cost                         | Deployment Size |     |        |     |         |
| 192263                                  | 819             |     |        |     |         |
| Function Name                           | min             | avg | median | max | # calls |
| getArrayLocation                        | 663             | 663 | 663    | 663 | 1       |

```



