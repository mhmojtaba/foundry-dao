// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {MyGovernor} from "src/Governor.sol";
import {MyContract} from "src/MyContract.sol";
import {TimeLock} from "src/Timelock.sol";
import {GovernanceToken} from "src/GovernanceToken.sol";

import {TimelockController} from "@openzeppelin/contracts/governance/TimeLockController.sol";
// import {DeployGovernor} from "script/DeployGovernor.s.sol";

contract GovernorTest is Test {
    MyGovernor governor;
    MyContract myContract;
    GovernanceToken governanceToken;
    TimeLock timelock;

    address public USER = makeAddr("user");
    uint256 public constant INITIAL_MINT = 10 ether;
    uint256 public constant MIN_DELAY = 3600;
    address[] public proposers = new address[](2);
    address[] public executors = new address[](2);

    function setUp() public {
        governanceToken = new GovernanceToken();
        governanceToken.mint(USER, INITIAL_MINT);

        vm.startPrank(USER);
        governanceToken.delegate(USER);
        timelock = new TimeLock(MIN_DELAY, proposers, executors);
        governor = new MyGovernor(governanceToken, TimelockController(address(timelock)));

        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.DEFAULT_ADMIN_ROLE();
        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(executorRole, address(0));
        timelock.revokeRole(adminRole, USER);

        vm.stopPrank();

        myContract = new MyContract();
        myContract.transferOwnership(address(timelock));
    }

    function testRevertUpdateWithoutGovernance() public {
        vm.expectRevert();
        myContract.setNumber(10);
    }

    function testGovernorUpdateContract() public {
        uint256 valueToStore = 100;
        
    }
}
