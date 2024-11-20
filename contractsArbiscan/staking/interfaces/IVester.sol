// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;
//NOTE: pragma was changed by fuzzer;

interface IVester {
    function claimForAccount(
        address _account,
        address _receiver
    ) external returns (uint256);

    function transferredAverageStakedAmounts(
        address _account
    ) external view returns (uint256);
    function transferredCumulativeRewards(
        address _account
    ) external view returns (uint256);
    function cumulativeRewardDeductions(
        address _account
    ) external view returns (uint256);
    function bonusRewards(address _account) external view returns (uint256);

    function transferStakeValues(address _sender, address _receiver) external;
    function setTransferredAverageStakedAmounts(
        address _account,
        uint256 _amount
    ) external;
    function setTransferredCumulativeRewards(
        address _account,
        uint256 _amount
    ) external;
    function setCumulativeRewardDeductions(
        address _account,
        uint256 _amount
    ) external;
    function setBonusRewards(address _account, uint256 _amount) external;

    function getMaxVestableAmount(
        address _account
    ) external view returns (uint256);
    function getCombinedAverageStakedAmount(
        address _account
    ) external view returns (uint256);

    //additional interface from fuzzer

    /**
     * @notice Get the pair amount for a specific account
     * @param account The address of the account to check
     * @return The pair amount for the account
     */
    function pairAmounts(address account) external view returns (uint256);

    /**
     * @notice Get the pair token address
     * @return The address of the pair token
     */
    function pairToken() external view returns (address);

    /**
     * @notice Check if contract has a pair token
     * @return True if the contract has a pair token, false otherwise
     */
    function hasPairToken() external view returns (bool);

    /**
     * @notice Get the total pair supply
     * @return The total supply of pair tokens
     */
    function pairSupply() external view returns (uint256);

    /**
     * @notice Calculate pair amount based on ES token amount
     * @param account The address of the account
     * @param esAmount The amount of ES tokens
     * @return The calculated pair amount
     */
    function getPairAmount(
        address account,
        uint256 esAmount
    ) external view returns (uint256);
}
