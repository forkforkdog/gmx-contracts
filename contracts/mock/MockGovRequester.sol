//SPDX-License-Identifier: MIT

pragma solidity 0.8.25;
//NOTE: pragma was changed by fuzzer

import "../peripherals/interfaces/ITimelock.sol";

contract MockGovRequester {
    function migrate(address timelock, address[] memory targets) external {
        ITimelock(timelock).requestGov(targets);
    }

    function afterGovGranted() external {}
}
