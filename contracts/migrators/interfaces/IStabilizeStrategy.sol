// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;
//NOTE: pragma was changed by fuzzer

interface IStabilizeStrategy {
    function governanceFinishMoveEsGMXFromDeprecatedRouter(
        address _sender
    ) external;
}
