
// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.8.0;


/*
  A custom error is abi encoded, thus, the error is packed in bytes and returned back to the caller as bytes for follow-up actions
    Whenever a custom error is triggered, its data will be packed in bytes and returned back to the caller, thus, allowing the caller to decode the data to take the required actions!
*/


contract A {
    address public admin;
    error myCustomError(uint number, address caller);

    constructor (address _admin) {
        require(_admin != address(0x00), "Zero address not allowed!");
        assert(_admin != 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);   // second Address on Remix
        admin = _admin;
    }

    function testFunction(uint _number) public view returns (string memory) {
        if(_number == 0) {
            revert myCustomError(_number, msg.sender);
        }
        return "testFunction() is called!";
    }

    // function testFunction(uint _number) public pure returns (string memory) {
    //     require(_number != 0, "_number cannot be 0!");
    //     return "testFunction() is called!";
    // }
}


contract B {
    event LogSuccesses(string message);
    event LogErrors(bytes data);

    A instanceofA;

    constructor() {
        instanceofA = new A(msg.sender);
    }

    function contractCreation(address _admin) public {
        try new A(_admin) {
            emit LogSuccesses("Contract A created!");
        } catch (bytes memory reason) {
            emit LogErrors(reason);
        }
    }

    function externalCall(uint _number) public {
        try instanceofA.testFunction(_number) returns (string memory result) {
            emit LogSuccesses(result);
        } catch (bytes memory reason) {
            emit LogErrors(reason);
        }
    }

    
}
