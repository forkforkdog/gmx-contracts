// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;
//NOTE: pragma was changed by fuzzer

contract UniFactory {
    mapping(address => mapping(address => mapping(uint24 => address)))
        public getPool;
}
