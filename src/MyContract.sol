// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MyContract is Ownable {
    uint256 private s_number;

    event changeNumber(uint256 number);

    constructor() Ownable(msg.sender) {}

    function setNumber(uint256 _number) public onlyOwner {
        s_number = _number;
        emit changeNumber(_number);
    }

    function getNumber() external view returns (uint256) {
        return s_number;
    }
}
