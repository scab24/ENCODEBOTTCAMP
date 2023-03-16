## Homework 5

```js
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BadgerCoin is ERC20 {
    constructor() ERC20("BadgerCoin", "BC") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}
````

- Transaction:
    - https://testnet.bscscan.com/tx/0x450ebf3201d56e6c40b67644ff8a4b2de9c26126d56bbff4dc98b1a5dfa560ba

- Contract:
    - https://testnet.bscscan.com/address/0x5a0f7e3cbe97217185b6b3f97e2f9b558a56ff4f

- Verification
    - Remix / contract.sol => right button / Flatten (generates the complete code so that you can verify the code correctly)

    - https://testnet.bscscan.com/address/0x5a0f7e3cbe97217185b6b3f97e2f9b558a56ff4f#code

- Write => https://testnet.bscscan.com/tx/0xafbdb45b57b3d8f1e7c5097e87e75df0b6a4f5b17aac3c320f8a314014021379
- Read => https://testnet.bscscan.com/address/0x5a0f7e3cbe97217185b6b3f97e2f9b558a56ff4f#readContract