// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;
//NOTE: pragma was changed by fuzzer

interface IGLP {
    function mint(address _account, uint256 _amount) external;
    function burn(address _account, uint256 _amount) external;
}
