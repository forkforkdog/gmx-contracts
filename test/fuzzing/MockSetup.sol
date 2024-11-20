// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// contract GmxDeployer {
//     // Core token addresses
//     address public gmx;
//     address public esGmx;
//     address public bnGmx;
//     address public glp;

//     // Reward tracking system
//     address public stakedGmxTracker;
//     address public stakedGmxDistributor;
//     address public bonusGmxTracker;
//     address public bonusGmxDistributor;
//     address public feeGmxTracker;
//     address public feeGmxDistributor;

//     // GLP system
//     address public feeGlpTracker;
//     address public feeGlpDistributor;
//     address public stakedGlpTracker;
//     address public stakedGlpDistributor;

//     // Vault system
//     address public vault;
//     address public usdg;
//     address public router;
//     address public glpManager;
//     address public vaultPriceFeed;

//     // Vesting & rewards
//     address public gmxVester;
//     address public glpVester;
//     address public rewardRouter;

//     function deployTokens() public {
//         // Core tokens
//         gmx = address(new GMX());
//         esGmx = address(new EsGMX());
//         bnGmx = address(new MintableBaseToken("Bonus GMX", "bnGMX", 0));
//         glp = address(new GLP());
//     }

//     function deployTrackingSystem() public {
//         // Deploy GMX tracking
//         stakedGmxTracker = address(new RewardTracker("Staked GMX", "sGMX"));
//         stakedGmxDistributor = address(
//             new RewardDistributor(esGmx, stakedGmxTracker)
//         );

//         bonusGmxTracker = address(
//             new RewardTracker("Staked + Bonus GMX", "sbGMX")
//         );
//         bonusGmxDistributor = address(
//             new BonusDistributor(bnGmx, bonusGmxTracker)
//         );

//         feeGmxTracker = address(
//             new RewardTracker("Staked + Bonus + Fee GMX", "sbfGMX")
//         );
//         feeGmxDistributor = address(
//             new RewardDistributor(address(weth), feeGmxTracker)
//         );

//         // Deploy GLP tracking
//         feeGlpTracker = address(new RewardTracker("Fee GLP", "fGLP"));
//         feeGlpDistributor = address(
//             new RewardDistributor(address(weth), feeGlpTracker)
//         );

//         stakedGlpTracker = address(
//             new RewardTracker("Fee + Staked GLP", "fsGLP")
//         );
//         stakedGlpDistributor = address(
//             new RewardDistributor(esGmx, stakedGlpTracker)
//         );

//         // Initialize trackers
//         RewardTracker(stakedGmxTracker).initialize(
//             [gmx, esGmx],
//             stakedGmxDistributor
//         );

//         RewardTracker(bonusGmxTracker).initialize(
//             [stakedGmxTracker],
//             bonusGmxDistributor
//         );

//         RewardTracker(feeGmxTracker).initialize(
//             [bonusGmxTracker, bnGmx],
//             feeGmxDistributor
//         );

//         RewardTracker(feeGlpTracker).initialize([glp], feeGlpDistributor);

//         RewardTracker(stakedGlpTracker).initialize(
//             [feeGlpTracker],
//             stakedGlpDistributor
//         );
//     }

//     function deployVaultSystem() public {
//         vault = address(new Vault());
//         usdg = address(new USDG(vault));
//         router = address(new Router(vault, usdg, weth));
//         vaultPriceFeed = address(new VaultPriceFeed());

//         // 24 hours for timelock
//         glpManager = address(
//             new GlpManager(
//                 vault,
//                 usdg,
//                 glp,
//                 address(0), // shortsTracker
//                 24 hours
//             )
//         );

//         // Initialize Vault
//         Vault(vault).initialize(router, usdg, vaultPriceFeed);
//     }

//     function deployVesting() public {
//         // 365 days vesting duration
//         uint256 vestingDuration = 365 days;

//         gmxVester = address(
//             new Vester(
//                 "Vested GMX", // _name
//                 "vGMX", // _symbol
//                 vestingDuration,
//                 esGmx, // _esToken
//                 feeGmxTracker, // _pairToken
//                 gmx, // _claimableToken
//                 stakedGmxTracker // _rewardTracker
//             )
//         );

//         glpVester = address(
//             new Vester(
//                 "Vested GLP", // _name
//                 "vGLP", // _symbol
//                 vestingDuration,
//                 esGmx, // _esToken
//                 stakedGlpTracker, // _pairToken
//                 gmx, // _claimableToken
//                 stakedGlpTracker // _rewardTracker
//             )
//         );
//     }

//     function deployRewardRouter() public {
//         rewardRouter = address(new RewardRouterV2());

//         RewardRouterV2(rewardRouter).initialize(
//             address(weth), // _weth
//             gmx, // _gmx
//             esGmx, // _esGmx
//             bnGmx, // _bnGmx
//             glp, // _glp
//             stakedGmxTracker,
//             bonusGmxTracker,
//             feeGmxTracker,
//             feeGlpTracker,
//             stakedGlpTracker,
//             glpManager,
//             gmxVester,
//             glpVester
//         );
//     }

//     function setPermissions() public {
//         // Set RewardRouter permissions
//         RewardTracker(stakedGmxTracker).setHandler(rewardRouter, true);
//         RewardTracker(bonusGmxTracker).setHandler(rewardRouter, true);
//         RewardTracker(feeGmxTracker).setHandler(rewardRouter, true);
//         RewardTracker(feeGlpTracker).setHandler(rewardRouter, true);
//         RewardTracker(stakedGlpTracker).setHandler(rewardRouter, true);

//         // Set cross-tracker permissions
//         RewardTracker(stakedGmxTracker).setHandler(bonusGmxTracker, true);
//         RewardTracker(bonusGmxTracker).setHandler(feeGmxTracker, true);
//         RewardTracker(feeGlpTracker).setHandler(stakedGlpTracker, true);

//         // Set GLP permissions
//         GLP(glp).setMinter(glpManager, true);
//         GlpManager(glpManager).setHandler(rewardRouter, true);

//         // Set private transfer modes
//         RewardTracker(stakedGmxTracker).setInPrivateTransferMode(true);
//         RewardTracker(bonusGmxTracker).setInPrivateTransferMode(true);
//         RewardTracker(feeGmxTracker).setInPrivateTransferMode(true);
//         RewardTracker(feeGlpTracker).setInPrivateTransferMode(true);
//         RewardTracker(stakedGlpTracker).setInPrivateTransferMode(true);

//         // Set private staking modes
//         RewardTracker(stakedGmxTracker).setInPrivateStakingMode(true);
//         RewardTracker(bonusGmxTracker).setInPrivateStakingMode(true);
//         RewardTracker(feeGmxTracker).setInPrivateStakingMode(true);
//         RewardTracker(feeGlpTracker).setInPrivateStakingMode(true);
//         RewardTracker(stakedGlpTracker).setInPrivateStakingMode(true);

//         // Set esGMX permissions
//         EsGMX(esGmx).setMinter(gmxVester, true);
//         EsGMX(esGmx).setMinter(glpVester, true);
//         EsGMX(esGmx).setMinter(rewardRouter, true);
//         EsGMX(esGmx).setHandler(rewardRouter, true);

//         // Set bnGMX permissions
//         MintableBaseToken(bnGmx).setMinter(rewardRouter, true);

//         // Set Vester permissions
//         Vester(gmxVester).setHandler(rewardRouter, true);
//         Vester(glpVester).setHandler(rewardRouter, true);
//     }

//     function initializeDistributors() public {
//         // Update distribution times
//         RewardDistributor(stakedGmxDistributor).updateLastDistributionTime();
//         RewardDistributor(stakedGlpDistributor).updateLastDistributionTime();
//         BonusDistributor(bonusGmxDistributor).updateLastDistributionTime();

//         // Set bonus multiplier
//         BonusDistributor(bonusGmxDistributor).setBonusMultiplier(10000); // 100%

//         // Set distribution rates
//         RewardDistributor(stakedGmxDistributor).setTokensPerInterval(
//             "20667989410000000"
//         ); // 0.02066798941 esGmx per second
//         RewardDistributor(stakedGlpDistributor).setTokensPerInterval(
//             "20667989410000000"
//         ); // 0.02066798941 esGmx per second
//     }

//     function deployAll() external {
//         deployTokens();
//         deployTrackingSystem();
//         deployVaultSystem();
//         deployVesting();
//         deployRewardRouter();
//         setPermissions();
//         initializeDistributors();
//     }
// }
