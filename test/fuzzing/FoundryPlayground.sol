// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./FuzzSetup.sol";
import "forge-std/Test.sol";

contract FoundryPlayground is FuzzSetup, Test {
    function setUp() public {
        setup();
    }

    function testRecheck() public pure {
        assert(false);
    }

    function test_8_stakeGMXandClaim() public {
        console.log("\n\ntest_8_stakeGMXandClaim()");
        console.log("__________________________\n");

        // Give user1 some GMX tokens
        vm.startPrank(owner);

        gmx.mint(user1, 100e18);
        vm.stopPrank();

        vm.startPrank(user1);

        // Log initial balances
        console.log("Initial GMX balance:", gmx.balanceOf(user1));
        console.log(
            "Initial staked amount:",
            stakedGmxTracker.stakedAmounts(user1)
        );
        console.log(
            "Initial staked tracker balance:",
            stakedGmxTracker.balanceOf(user1)
        );

        // Approve staking
        console.log("\nApproving GMX for staking...");
        gmx.approve(address(stakedGmxTracker), 100e18);

        // Stake GMX
        console.log("\nStaking GMX...");
        rewardRouterV2.stakeGmx(100e18);

        // Log post-staking balances
        console.log("\nPost-staking balances:");
        console.log("GMX balance:", gmx.balanceOf(user1));
        console.log(
            "StakedGMXTracker balance:",
            stakedGmxTracker.balanceOf(user1)
        );
        console.log(
            "BonusGMXTracker balance:",
            bonusGmxTracker.balanceOf(user1)
        );
        console.log(
            "ExtendedGMXTracker balance:",
            extendedGmxTracker.balanceOf(user1)
        );
        console.log("FeeGMXTracker balance:", feeGmxTracker.balanceOf(user1));

        // Log staked amounts
        console.log("\nStaked amounts:");
        console.log("StakedGMXTracker:", stakedGmxTracker.stakedAmounts(user1));
        console.log("BonusGMXTracker:", bonusGmxTracker.stakedAmounts(user1));
        console.log(
            "ExtendedGMXTracker:",
            extendedGmxTracker.stakedAmounts(user1)
        );
        console.log("FeeGMXTracker:", feeGmxTracker.stakedAmounts(user1));

        // Claim rewards
        console.log("\nClaiming rewards...");
        rewardRouterV2.claim();

        vm.stopPrank();
    }
}
