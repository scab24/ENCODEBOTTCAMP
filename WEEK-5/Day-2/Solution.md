# Homework 17


## Code 

```js
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import "lib/openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import "lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

contract UpgradeMe is UUPSUpgradeable, Initializable {
    enum PaymentOptions {Pay, Borrow, Defer, Extra}

    PaymentOptions options;
    PaymentOptions constant defaultChoice = PaymentOptions.Pay;

    mapping(address => uint256) internal balance;
    uint256 initialBlock;
    uint256 nextPayout = 0;
    string constant name = "Payout Tool";
    address immutable owner;

//change constructor to function initialize
    function initialize(address _owner) initializer public {
        __UUPSUpgradeable_init();
        owner = _owner;
        initialBlock = block.number;
        nextPayout = initialBlock;
    }

    function processPayment(PaymentOptions _option, address _to, uint256 _amount) virtual public {
        uint256 surcharge = 10;

        if (_option == PaymentOptions.Extra) {
            surcharge = 20;
        }
        if (_to == owner) {
            surcharge = 0;
        }
        uint256 transferAmount = _amount + surcharge;
        require(balance[msg.sender] > transferAmount, "Low Balance");
        balance[msg.sender] = balance[msg.sender] - transferAmount;
        balance[_to] = balance[_to] + transferAmount;

    // Update the next payout block to be the current block
    nextPayout = block.number;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    uint256[50] private __gap;
}

```