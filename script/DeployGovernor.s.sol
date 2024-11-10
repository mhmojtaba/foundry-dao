// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.24;

// import {Script , console} from "forge-std/Script.sol";
// import {MyGovernor} from "src/Governor.sol";
// import {MyContract} from "src/MyContract.sol";
// import {TimeLock} from "src/Timelock.sol";
// import {GovernanceToken} from "src/GovernanceToken.sol";

// contract DeployGovernor is Script{
//     MyGovernor governor;
//     MyContract myContract;
//     GovernanceToken governanceToken;
//     TimeLock timelock;

//     uint256 public constant MIN_DELAY = 3600;
//    address[] public proposers;
//     address[] public executors;
//     function run() public returns(TimeLock,MyGovernor,MyContract,GovernanceToken){
//         myContract = new MyContract();
//         governanceToken = new GovernanceToken();
//         timelock = new TimeLock(MIN_DELAY,proposers,executors);
//         governor = new MyGovernor(governanceToken , timelock);

//         return (myContract , governor , timelock , governanceToken);
//     }
// }
