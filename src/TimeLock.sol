// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {TimelockController} from "@openzeppelin/contracts/governance/TimeLockController.sol";

contract TimeLock is TimelockController {
    // mindelay is the minimum delay before execution
    // proposers is the list of addresses that can propose
    // executors is the list of addresses that can execute
    constructor(uint256 minDelay, address[] memory proposers, address[] memory executors)
        TimelockController(minDelay, proposers, executors, msg.sender)
    {}
}
