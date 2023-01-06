Logic Contract: 0xAe7a6A85738Ed16F77068fc11C2329E528635786  (Called.sol)
Proxy Contract: 0xa9FC948555473c7cefF87373B5593D3d6982369B  (Caller.sol)


-----------


There is a proxy contract to delegateCall() onto the logic contracts!	<----> Proxi Contract
	- The proxy is really used only to upgrade the logic



Suppose you have a private liquidity pool where users can ask for loans from	<----> Logic Contract

	- The maximum number of providers is 10
	* The provider's addresses are stored in an array!

		- There is a method to close the liquidity pool that requires at least 50% of the providers to agree with					<---> This is the method that will be attacked once the attacker gains ownership of the LP
			- When the pool is closed, all the existing liquidity and all the accrued interests are split among all the providers

		* Users ask for a loan and pay interest on it

	

* There is a library that is used to "save" some gas when deploying the private LPs contracts
	- in the library exists a method to initialize the owners of the private LP (initLiquidityPool)
		* This is the method that will be compromised
			- Receives an array of owners
			- Receives the minimum deposit amount to be deposited by the owners
			- Receives an uint that indicates the initial interest % that will be charged to users for borrowing


	- And a bunch of other methods that might reusable ....


