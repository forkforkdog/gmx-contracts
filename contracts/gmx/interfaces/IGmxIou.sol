// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;
//NOTE: pragma was changed by fuzzer

interface IGmxIou {
    function mint(address account, uint256 amount) external returns (bool);
}
