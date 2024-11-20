// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;
//NOTE: pragma was changed by fuzzer

interface ITimelock {
    function marginFeeBasisPoints() external returns (uint256);
    function setAdmin(address _admin) external;
    function enableLeverage(address _vault) external;
    function disableLeverage(address _vault) external;
    function setIsLeverageEnabled(
        address _vault,
        bool _isLeverageEnabled
    ) external;
    function signalSetGov(address _target, address _gov) external;
    function setGov(address _target) external;
    function requestGov(address[] memory _targets) external;
}
