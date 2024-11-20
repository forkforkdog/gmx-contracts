// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;
//NOTE: pragma was changed by fuzzer

interface IFastPriceEvents {
    function emitPriceEvent(address _token, uint256 _price) external;
}
