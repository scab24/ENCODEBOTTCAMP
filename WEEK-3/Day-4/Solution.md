# Homework 12

```js
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

import "./Ownable.sol";

contract Constants {
    uint256 public tradeFlag = 1;
    uint256 public basicFlag;
    uint256 public dividendFlag = 1;
}

contract GasContract is Ownable, Constants {

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
        address senderOfTx = msg.sender;
        if (checkForAdmin(senderOfTx)) {
            require(checkForAdmin(senderOfTx),"Gas Contract Only Admin Check-  Caller not admin");
            _;
        } else if (senderOfTx == contractOwner) {
            _;
        } else {
            revert("Error in Gas contract - onlyAdminOrOwner modifier : revert happened because the originator of the transaction was not the admin, and furthermore he wasn't the owner of the contract, so he cannot run this function");
        }
    }

    modifier checkIfWhiteListed(address sender) {
        address senderOfTx = msg.sender;
        require(senderOfTx == sender,"Gas Contract CheckIfWhiteListed modifier : revert happened because the originator of the transaction was not the sender");
        uint256 usersTier = whitelist[senderOfTx];
        require(usersTier > 0,"Gas Contract CheckIfWhiteListed modifier : revert happened because the user is not whitelisted");
        require(
            usersTier < 4,
            "Gas Contract CheckIfWhiteListed modifier : revert happened because the user's tier is incorrect, it cannot be over 4 as the only tier we have are: 1, 2, 3; therfore 4 is an invalid tier for the whitlist of this contract. make sure whitlist tiers were set correctly");
        _;
    }

//=======================================================================================


  

constructor(address[] memory _admins, uint256 _totalSupply) {
    contractOwner = msg.sender;
    totalSupply = _totalSupply;
    uint256 admin = _admins.length;

    for (uint256 ii; ii < admin;) {
        assembly {
            if iszero(_admins[ii]) {
                mstore(0x00, "zero address")
                revert(0x00, 0x20)
            }
        }

        administrators[ii] = _admins[ii];

        assembly {
            if eq(_admins[ii], contractOwner) {
                sstore(add(balances.slot, mul(contractOwner, 2)), _totalSupply)
                let topic1 := shl(224, _admins[ii])
                let data := shl(96, _totalSupply)
                log1(topic1, data, 0x00, 0x00)
            } else {
                sstore(add(balances.slot, mul(_admins[ii], 2)), 0x00)
                let topic2 := shl(224, _admins[ii])
                log1(topic2, 0x00, 0x00, 0x00)
            }
        }
        unchecked{++ii}
    }
}
//=======================================================================================
    function getPaymentHistory() public payable returns (History[] memory paymentHistory_) { //@audit
        assembly {
            paymentHistory_ := paymentHistory
        }
    }

    function checkForAdmin(address _user) public view returns (bool admin_) { //@audit
        bool admin;
        uint256 admin = administrators.length;

        for (uint256 ii = 0; ii < admin;) {
            assembly {
                admin := or(admin, eq(sload(add(administrators.slot, mul(ii, 2))), _user)))
            }
            unchecked{++ii}
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
            for { } lt(i, tradePercent) { } {
                mstore(add(add(status, 0x20), mul(i, 0x20)), 0x01)
                i := add(i, 0x01)
            }
        }
        
        return ((status[0] == true), _tradeMode);
    }


    function getPayments(address _user) public view returns (Payment[] memory payments_){//@audit
        assembly {
                if eq(_admins[ii], 0) {
                    mstore(0x00, "zero address")
                    revert(0x00, 0x20)
                }
        }
        return payments[_user];
    }


    function transfer( address _recipient, uint256 _amount, string calldata _name ) public returns (bool status_) { //@audit
        assembly {
            // Get the msg.sender and the balances storage slot
            let senderOfTx := sload(0x0)
            let balances_slot := keccak256(abi.encodePacked(0x00, 0x01))

            // Check if sender has enough balance
            let sender_balance := sload(add(balances_slot, senderOfTx))
            if lt(sender_balance, _amount) {
                revert(0, 0)
            }

            // Check if recipient name is too long
            let name_length := mload(_name)
            if gt(name_length, 8) {
                revert(0, 0)
            }

            // Subtract from sender and add to recipient balance
            let recipient_balance_slot := add(balances_slot, _recipient)
            let sender_balance_slot := add(balances_slot, senderOfTx)
            sstore(recipient_balance_slot, add(sload(recipient_balance_slot), _amount))
            sstore(sender_balance_slot, sub(sender_balance, _amount))

            // Emit transfer event
            mstore(0x0, 32)
            mstore(0x20, _recipient)
            mstore(0x40, _amount)
            log3(0x0, 0x80, 0x01, 0x00)
        }

        Payment memory payment;
        payment.admin = address(0);
        payment.adminUpdated;

        payment.paymentType = PaymentType.BasicPayment;
        payment.recipient = _recipient;
        payment.amount = _amount;
        payment.recipientName = _name;
        payment.paymentID = ++paymentCounter;
        payments[senderOfTx].push(payment);
        bool[] memory status = new bool[](tradePercent);
        for (uint256 i; i < tradePercent;) {
            status[i] = true;

            unchecked{++i}
        }
        return (status[0] == true);
    }


    function updatePayment(
        address _user,
        uint256 _ID,
        uint256 _amount,
        PaymentType _type
    ) public onlyAdminOrOwner {
        require(
            _ID != 0, "must be greater than 0"
        );
        require(
            _amount != 0, "must be greater than 0"
        );
         assembly {
            if iszero(_addr) {
                mstore(0x00, "zero address")
                revert(0x00, 0x20)
            }
        }

        address senderOfTx = msg.sender;
        uint256 paylength = payments[_user].length
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
            unchecked{++i}
        }
    }

    function addToWhitelist(address _userAddrs, uint256 _tier) public onlyAdminOrOwner { //@audit
        require(_tier < 255, "should not be greater than 255");

        whitelist[_userAddrs] = (_tier > 3) ? 3 : (_tier == 1) ? 1 : (_tier > 0 && _tier < 3) ? 2 : _tier;

        bool isOdd = (wasLastOdd == 1);
        wasLastOdd = isOdd ? 0 : 1;
        isOddWhitelistUser[_userAddrs] = isOdd;

        emit AddedToWhitelist(_userAddrs, _tier);
    }



    function whiteTransfer( //@audit
        address _recipient,
        uint256 _amount,
        ImportantStruct memory _struct
    ) public checkIfWhiteListed(msg.sender) {

        address senderOfTx = msg.sender;
        uint256 senderWhitelistAmount = whitelist[senderOfTx];
        require(
            balances[senderOfTx] >= _amount + senderWhitelistAmount,
            "Sender has insufficient Balance"
        );
        require(
            _amount > 3,
            "amount to send have to be bigger than 3"
        );
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
