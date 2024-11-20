// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;
//NOTE: pragma was changed by fuzzer

interface IChainlinkFlags {
    function getFlag(address) external view returns (bool);
}
