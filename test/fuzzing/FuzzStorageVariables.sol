// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
// Core Tokens
import {GMX} from "../../contracts/gmx/GMX.sol";
import {EsGMX} from "../../contractsArbiscan/gmx/EsGMX.sol";
import {MintableBaseToken} from "../../contractsArbiscan/tokens/MintableBaseToken.sol";
import {GLP} from "../../contracts/gmx/GLP.sol";
import {USDG} from "../../contracts/tokens/USDG.sol";

// Base Tokens & Price Feeds
import {Token} from "../../contracts/tokens/Token.sol";
import {PriceFeed} from "../../contracts/oracle/PriceFeed.sol";

// Core System
import {Vault} from "../../contracts/core/Vault.sol";
import {Router} from "../../contracts/core/Router.sol";
import {VaultPriceFeed} from "../../contracts/core/VaultPriceFeed.sol";
import {GlpManager} from "../../contracts/core/GlpManager.sol";

// Reward System
import {RewardTracker} from "../../contractsArbiscan/staking/RewardTracker.sol";
import {Vester} from "../../contractsArbiscan/staking/Vester.sol";
import {RewardRouterV2} from "../../contractsArbiscan/staking/RewardRouterV2.sol";

import {RewardDistributor} from "../../contracts/staking/RewardDistributor.sol";
import {BonusDistributor} from "../../contracts/staking/BonusDistributor.sol";

import {MockExternalHandler} from "../../contracts/mock/MockExternalHandler.sol";

// Reader
import {Reader} from "../../contracts/peripherals/Reader.sol";
import {Timelock} from "../../contracts/peripherals/Timelock.sol";

contract FuzzStorageVariables {
    address public owner = address(0x10101);
    address public user1 = address(0x10000);

    // Base Tokens
    Token public bnb;
    Token public btc;
    Token public eth;
    Token public dai;

    // Price Feeds
    PriceFeed public bnbPriceFeed;
    PriceFeed public btcPriceFeed;
    PriceFeed public ethPriceFeed;
    PriceFeed public daiPriceFeed;

    // Core System
    Vault public vault;
    USDG public usdg;
    Router public router;
    VaultPriceFeed public vaultPriceFeed;

    // GLP System
    GLP public glp;
    GlpManager public glpManager;

    // Core Tokens
    GMX public gmx;
    EsGMX public esGmx;
    MintableBaseToken public bnGmx;
    MintableBaseToken public govToken; // Added for V2

    // Reward System - GMX
    RewardTracker public stakedGmxTracker;
    RewardDistributor public stakedGmxDistributor;
    RewardTracker public bonusGmxTracker;
    BonusDistributor public bonusGmxDistributor;
    RewardTracker public extendedGmxTracker; // Added for V2
    RewardDistributor public extendedGmxDistributor; // Added for V2
    RewardTracker public feeGmxTracker;
    RewardDistributor public feeGmxDistributor;

    // Reward System - GLP
    RewardTracker public feeGlpTracker;
    RewardDistributor public feeGlpDistributor;
    RewardTracker public stakedGlpTracker;
    RewardDistributor public stakedGlpDistributor;

    // Vesting
    uint256 public constant vestingDuration = 365 days; // Added for V2
    Vester public gmxVester;
    Vester public glpVester;

    // Router
    RewardRouterV2 public rewardRouterV2;

    // External Handler
    MockExternalHandler public mockExternalHandler; // Added for V2

    // Reader
    Reader public gmxReader;

    // Timelock
    Timelock public timelock; // Added for V2
}
