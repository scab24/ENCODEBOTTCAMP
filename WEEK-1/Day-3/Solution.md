## Homework 3

### ABI
- https://gnidan.github.io/abi-to-sol/

```js
[
	{
		"inputs": [],
		"name": "retrieve",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "num",
				"type": "uint256"
			}
		],
		"name": "store",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]
```

- The Application Binary Interface or ABI is the standard way to interact with contracts in the Ethereum ecosystem, both from outside the blockchain and in contract-contract interactions.
- It shows the characteristics of our code in an easy to understand way.

### Bytecode

```js
608060405234801561001057600080fd5b50610150806100206000396000f3fe608060405234801561001057600080fd5b50600436106100365760003560e01c80632e64cec11461003b5780636057361d14610059575b600080fd5b610043610075565b60405161005091906100d9565b60405180910390f35b610073600480360381019061006e919061009d565b61007e565b005b60008054905090565b8060008190555050565b60008135905061009781610103565b92915050565b6000602082840312156100b3576100b26100fe565b5b60006100c184828501610088565b91505092915050565b6100d3816100f4565b82525050565b60006020820190506100ee60008301846100ca565b92915050565b6000819050919050565b600080fd5b61010c816100f4565b811461011757600080fd5b5056fea26469706673582212209d81150c9dbf4d7b7890855470404c7452cb8e159cd80e11b5fd318e763e042064736f6c63430008070033
````


- It is our contract written at a low level so that it can be understood by the EVM.
- https://www.evm.codes/playground?unit=Wei&callData=0x6057361d000000000000000000000000000000000000000000000000000000000000000a&codeType=Mnemonic&code=%27%210%7E0KCALLDATALOAD%7E2z2qw%21E0%7E3KSHR%7E5z2qwDUP1%7E6%28X4_2E64CEC1%7E7KEQ%7E12z5qwX2_3B%7E13%28*I%7E16z3qwDUP1%7E17KX4_6057361D%7E18KEQ%7E23z5qwX2_59%7E24K*I%7E27z3qwkY+wX30_0%7E28KwZGV59z31q%211%7E60+%7BG%7DW%7DKwkYwX26_0%7E62z2qKZstore%7Buint256V89z27q%210+ZContinueW.KK%27%7E+ZOffset+z+%7Bprevious+instruFoccupies+w%5Cnq%29s%7DwkZThes-ar-just+paddingNenabl-usNgetN_+0xZ%2F%2F+Yprogram+counter+59+%26+89XPUSHW+funFexecution...V%7D%29codew*DEST%7EN+to%28wwGretrieve%7BFction+-e+*JUMP%29+byte%28+K%21X1_%01%21%28%29*-FGKNVWXYZ_kqwz%7E_&fork=merge