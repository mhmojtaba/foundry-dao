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
    uint256 public constant VOTING_DELAY = 1;
    uint256 public constant VOTING_PERIOD = 50400;
    address[] public proposers = new address[](2);
    address[] public executors = new address[](2);
    uint256[] public values;
    bytes[] memory calldatas;
    address[] memory targets;

    function setUp() public {
        governanceToken = new GovernanceToken();
        governanceToken.mint(USER, INITIAL_MINT);

        vm.startPrank(USER);
        governanceToken.delegate(USER);
        timelock = new TimeLock(MIN_DELAY, proposers, executors);
        governor = new MyGovernor(governanceToken, payable(timelock));

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
        string memory description = "store value in contract";
        bytes memory callFunction = abi.encodeWithSignature("setNumber(uint256)", valueToStore);
        targets.push(address(myContract));
        values.push(0);
        calldatas.push(callFunction);

        //1. propose to the DAO
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        // view the state
        console.log("propose state: ", uint256(governor.state(proposalId)));
        vm.warp(block.timestamp + VOTING_DELAY +1);
        vm.roll(block.number + VOTING_DELAY +1);

        console.log("propose state: ", uint256(governor.state(proposalId)));

        //2. vote for the proposal
        string memory reason = "reason";
        uint8 support = 1;
        vm.startPrank(USER); 
        governor.castVoteWithReason(proposalId , support, reason);

        vm.warp(block.timestamp + VOTING_PERIOD +1);
        vm.roll(block.number + VOTING_PERIOD +1); // after 1 week

        // 3. queue the proposal
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        governor.queue(targets , values, calldatas, descriptionHash);
        
        vm.warp(block.timestamp + MIN_DELAY +1);
        vm.roll(block.number + MIN_DELAY +1); 

        // 4. execute the proposal
        timelock.execute(targets , values, calldatas, descriptionHash);

        console.log("new number: ", myContract.getNumber());
        assert(myContract.getNumber() == valueToStore);
    }
}
