# Homework 12

## Result

- 28.09% 

## Optimization

```js
·----------------------------------|----------------------------|-------------|-----------------------------·
|       Solc version: 0.8.0        ·  Optimizer enabled: false  ·  Runs: 200  ·  Block limit: 30000000 gas  │
···································|····························|·············|······························
|  Methods                                                                                                  │
················|··················|··············|·············|·············|···············|··············
|  Contract     ·  Method          ·  Min         ·  Max        ·  Avg        ·  # calls      ·  usd (avg)  │
················|··················|··············|·············|·············|···············|··············
|  GasContract  ·  addToWhitelist  ·       80675  ·      82794  ·      81767  ·         2400  ·          -  │
················|··················|··············|·············|·············|···············|··············
|  GasContract  ·  transfer        ·      169216  ·     220540  ·     194880  ·           20  ·          -  │
················|··················|··············|·············|·············|···············|··············
|  GasContract  ·  updatePayment   ·           -  ·          -  ·     206791  ·            2  ·          -  │
················|··················|··············|·············|·············|···············|··············
|  GasContract  ·  whiteTransfer   ·           -  ·          -  ·     122676  ·            6  ·          -  │
················|··················|··············|·············|·············|···············|··············
|  Deployments                     ·                                          ·  % of limit   ·             │
···································|··············|·············|·············|···············|··············
|  GasContract                     ·           -  ·          -  ·    3346974  ·       11.2 %  ·          -  │
·----------------------------------|--------------|-------------|-------------|---------------|-------------·
```


## Optimized Contract 
```js
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

import "./Ownable.sol";

contract GasContract is Ownable {

//=======================================================================================
    
    event AddedToWhitelist(address userAddress, uint256 tier);
    event supplyChanged(address indexed, uint256 indexed);
    event Transfer(address recipient, uint256 amount);
    event PaymentUpdated(
        address admin,
        uint256 ID,
        uint256 amount,
        string recipient
    );
    event WhiteListTransfer(address indexed);

//=======================================================================================

    uint256 public tradeFlag = 1;
    uint256 public basicFlag;
    uint256 public dividendFlag = 1;

    uint256 public totalSupply; // cannot be updated
    uint256 public paymentCounter;
    uint256 public tradePercent = 12;
    uint256 public tradeMode;
    uint256 wasLastOdd = 1;

//=======================================================================================

    PaymentType constant defaultPayment = PaymentType.Unknown;

    History[] public paymentHistory; // when a payment was updated
//=======================================================================================

    mapping(address => uint256) public balances;
    mapping(address => Payment[]) public payments;
    mapping(address => uint256) public whitelist;
    mapping(address => uint256) public isOddWhitelistUser;
    mapping(address => ImportantStruct) public whiteListStruct;

//=======================================================================================

    address public contractOwner;
    address[5] public administrators;

//=======================================================================================

    bool public isReady;

//=======================================================================================

    struct Payment {
        PaymentType paymentType;
        uint256 paymentID;
        uint256 amount;
        bool adminUpdated;
        string recipientName; // max 8 characters
        address recipient;
        address admin; // administrators address
       
    }

    struct History {
        uint256 lastUpdate;
        uint256 blockNumber;
        address updatedBy;
     
    }

    
    struct ImportantStruct {
        uint256 valueA; // max 3 digits
        uint256 bigValue;
        uint256 valueB; // max 3 digits
    }

//=======================================================================================

    enum PaymentType {
        Unknown,
        BasicPayment,
        Refund,
        Dividend,
        GroupPayment
    }

//=======================================================================================

    modifier onlyAdminOrOwner() {
        require(checkForAdmin(msg.sender) || msg.sender == contractOwner, "Caller not authorized");
        _;
    }


    modifier checkIfWhiteListed(address sender) {
        require(msg.sender == sender && whitelist[sender] > 0 && whitelist[sender] < 4, "Access denied");
        _;
    }


//=======================================================================================

    constructor(address[] memory _admins, uint256 _totalSupply) {
        contractOwner = msg.sender;
        totalSupply = _totalSupply;

        for (uint256 ii = 0; ii < administrators.length; ii++) {
            if (_admins[ii] != address(0)) {
                administrators[ii] = _admins[ii];
                if (_admins[ii] == contractOwner) {
                    balances[contractOwner] = totalSupply;
                } else {
                    balances[_admins[ii]] = 0;
                }
                if (_admins[ii] == contractOwner) {
                    emit supplyChanged(_admins[ii], totalSupply);
                } else if (_admins[ii] != contractOwner) {
                    emit supplyChanged(_admins[ii], 0);
                }
            }
        }
    }

    function getPaymentHistory() public payable returns (History[] memory paymentHistory_) { //@audit
        assembly {
            paymentHistory_ := paymentHistory.slot
        }
    }

    function checkForAdmin(address _user) public view returns (bool admin_) {
        bool admin = false;
        for (uint256 ii = 0; ii < administrators.length; ii++) {
            if (administrators[ii] == _user) {
                admin = true;
            }
        }
        return admin;
    }

    function balanceOf(address _user) public view returns (uint256 balance_) {
        uint256 balance = balances[_user];
        return balance;
    }

    function getTradingMode() public view returns (bool mode_) { //@audit
        bool mode;
        assembly {
            let flag1 := sload(tradeFlag.slot)
            let flag2 := sload(dividendFlag.slot)
            mode := or(eq(flag1, 1), eq(flag2, 1))
        }
        return mode;
    }

    function addHistory(address _updateAddress, bool _tradeMode) public returns (bool status_, bool tradeMode_){ //@audit
        History memory history;
        history.blockNumber = block.number;
        history.lastUpdate = block.timestamp;
        history.updatedBy = _updateAddress;
        paymentHistory.push(history);
        bool[] memory status = new bool[](tradePercent);
        
        assembly {
            let i := 0
            for { } lt(i, tradePercent.slot) { } {
                mstore(add(add(status, 0x20), mul(i, 0x20)), 0x01)
                i := add(i, 0x01)
            }
        }
        
        return ((status[0] == true), _tradeMode);
    }

    function getPayments(address _user) public view returns (Payment[] memory payments_){
        assembly {
                if eq(_user, 0) {
                    mstore(0x00, "zero address")
                    revert(0x00, 0x20)
                }
        }
        return payments[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) public returns (bool status_) {
        address senderOfTx = msg.sender;

        require(
            balances[senderOfTx] >= _amount,
            "Sender has insufficient Balance" );
        require(
            bytes(_name).length < 9,
            "there is a max length of 8 characters" );

        balances[senderOfTx] -= _amount;
        balances[_recipient] += _amount;

        emit Transfer(_recipient, _amount);

        Payment memory payment;
        payment.admin = address(0);
        payment.adminUpdated = false;
        payment.paymentType = PaymentType.BasicPayment;
        payment.recipient = _recipient;
        payment.amount = _amount;
        payment.recipientName = _name;
        payment.paymentID = ++paymentCounter;
        payments[senderOfTx].push(payment);
        bool[] memory status = new bool[](tradePercent);
        
        for (uint256 i; i < tradePercent; ++i) {
            status[i] = true;
        }
        return (status[0] == true);
    }

    function updatePayment( address _user, uint256 _ID, uint256 _amount, PaymentType _type ) public onlyAdminOrOwner {

        require(_ID != 0, "must be greater than 0" );
        require( _amount != 0, "must be greater than 0");
        
        assembly {
            if iszero(_user) {
                mstore(0x00, "zero address")
                revert(0x00, 0x20)
            }
        }

        address senderOfTx = msg.sender;
        uint256 paylength = payments[_user].length;
        for (uint256 ii; ii < paylength;) {

            if (payments[_user][ii].paymentID == _ID) {

                payments[_user][ii].adminUpdated = true;
                payments[_user][ii].admin = _user;
                payments[_user][ii].paymentType = _type;
                payments[_user][ii].amount = _amount;

                bool tradingMode = getTradingMode();
                addHistory(_user, tradingMode);

                emit PaymentUpdated(
                    senderOfTx,
                    _ID,
                    _amount,
                    payments[_user][ii].recipientName
                );
            }
            unchecked{++ii;}
        }
    }

    function addToWhitelist(address _userAddrs, uint256 _tier) public onlyAdminOrOwner { //@audit
        require(_tier < 255, "should not be greater than 255");

        whitelist[_userAddrs] = (_tier > 3) ? 3 : (_tier == 1) ? 1 : (_tier > 0 && _tier < 3) ? 2 : _tier;

        bool isOdd = (wasLastOdd == 1);
        wasLastOdd = isOdd ? 0 : 1;
        isOddWhitelistUser[_userAddrs] = isOdd ? 1 : 0;

        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer( //@audit
        address _recipient,
        uint256 _amount,
        ImportantStruct memory _struct
    ) public checkIfWhiteListed(msg.sender) {

        address senderOfTx = msg.sender;
        uint256 senderWhitelistAmount = whitelist[senderOfTx];

        require(balances[senderOfTx] >= _amount + senderWhitelistAmount,"Sender has insufficient Balance");
        require(_amount > 3,"amount to send have to be bigger than 3");

        balances[senderOfTx] -= _amount + senderWhitelistAmount;
        balances[_recipient] += _amount;

        whiteListStruct[senderOfTx] = ImportantStruct(0, 0, 0);
        ImportantStruct storage newImportantStruct = whiteListStruct[senderOfTx];
        newImportantStruct.valueA = _struct.valueA;
        newImportantStruct.bigValue = _struct.bigValue;
        newImportantStruct.valueB = _struct.valueB;

        emit WhiteListTransfer(_recipient);
    }
}
```
