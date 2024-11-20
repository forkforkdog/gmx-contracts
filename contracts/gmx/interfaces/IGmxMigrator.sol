// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;
//NOTE: pragma was changed by fuzzer

interface IGmxMigrator {
    function iouTokens(address _token) external view returns (address);
}
