// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;
//NOTE: pragma was changed by fuzzer

import "./interfaces/IRewardTracker.sol";
import "../access/Governable.sol";

contract StakeManager is Governable {
    function stakeForAccount(
        address _rewardTracker,
        address _account,
        address _token,
        uint256 _amount
    ) external onlyGov {
        IRewardTracker(_rewardTracker).stakeForAccount(
            _account,
            _account,
            _token,
            _amount
        );
    }
}
