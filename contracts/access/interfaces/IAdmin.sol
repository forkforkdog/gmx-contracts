//SPDX-License-Identifier: MIT

pragma solidity 0.8.25;
//NOTE: pragma was changed by fuzzer

interface IAdmin {
    function setAdmin(address _admin) external;
}
