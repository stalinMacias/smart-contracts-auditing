pragma solidity 0.8.10;

import "forge-std/Test.sol";

import "../src/StakeContract.sol";
import "./mocks/MockERC20.sol";

// Writing Foundry Tests documentation => https://book.getfoundry.sh/forge/writing-tests

contract StakeContractTest is Test {
    StakeContract public stakeContract;
    MockERC20 public mockToken; 

    // setUp() function is always executed before running a test() function
    function setUp() public {
        stakeContract = new StakeContract();
        mockToken = new MockERC20();
    }

    // functions prefixed with test are run as a test case
    // when test() functionas has parameters, Foundry will run a fuzz test
    function test_staking_tokens_fuzz(uint8 amount) public {
        mockToken.approve(address(stakeContract), amount);
        bool stakePassed = stakeContract.stake(amount, address(mockToken));
        assertTrue(stakePassed);
    }

    // testFail: The inverse of the test prefix - if the function does not revert, the test fails.
    function testFail_Subtract43(uint8 testNumber) public {
        testNumber -= 43;
    }

}