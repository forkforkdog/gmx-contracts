// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;
//NOTE: pragma was changed by fuzzer

interface IGMT {
    function beginMigration() external;
    function endMigration() external;
}
