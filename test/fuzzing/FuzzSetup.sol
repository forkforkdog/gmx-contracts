pragma solidity 0.8.25;
//NOTE: pragma was changed by fuzzer

import "./FuzzStorageVariables.sol";

contract FuzzSetup is FuzzStorageVariables {
    function setup() internal {
        step1_deployBaseTokensAndFeeds();
        step2_deployCoreSystem();
        step3_deployRewardTokens();
        step4_setupGmxRewards();
        step5_setupGlpRewards();
        step6_setupExtendedRewards();
        step7_setupNewRewardRouter();
        step8_approvals();
    }

    function step1_deployBaseTokensAndFeeds() public {
        // Deploy tokens
        bnb = new Token();
        btc = new Token();
        eth = new Token();
        dai = new Token();

        // Deploy price feeds
        bnbPriceFeed = new PriceFeed();
        btcPriceFeed = new PriceFeed();
        ethPriceFeed = new PriceFeed();
        daiPriceFeed = new PriceFeed();
    }
    // STEP 2: Deploy and initialize core system
    function step2_deployCoreSystem() public {
        // Deploy core contracts
        vault = new Vault();
        usdg = new USDG(address(vault));
        router = new Router(address(vault), address(usdg), address(bnb));
        vaultPriceFeed = new VaultPriceFeed();
        glp = new GLP();

        govToken = new MintableBaseToken("GOV", "GOV", 0);

        // Initialize main vault
        vault.initialize(
            address(router), // router
            address(usdg), // usdg
            address(vaultPriceFeed), // priceFeed
            5 * 1e30, // liquidationFeeUsd (5 USD)
            600, // fundingRateFactor
            600 // stableFundingRateFactor
        );

        // // Initialize VaultUtils
        // vaultUtils = new VaultUtils(address(vault));
        // vault.setVaultUtils(address(vaultUtils));

        // // Initialize VaultErrorController
        // vaultErrorController = new VaultErrorController();
        // vault.setErrorController(address(vaultErrorController));
        // vaultErrorController.setErrors(address(vault), errors);

        // Initialize GlpManager with 24 hour cooldown
        glpManager = new GlpManager(
            address(vault),
            address(usdg),
            address(glp),
            address(0),
            24 hours
        );

        // Setup price feeds
        vaultPriceFeed.setTokenConfig(
            address(bnb),
            address(bnbPriceFeed),
            8,
            false
        );
        vaultPriceFeed.setTokenConfig(
            address(btc),
            address(btcPriceFeed),
            8,
            false
        );
        vaultPriceFeed.setTokenConfig(
            address(eth),
            address(ethPriceFeed),
            8,
            false
        );
        vaultPriceFeed.setTokenConfig(
            address(dai),
            address(daiPriceFeed),
            8,
            false
        );

        // Set token prices
        daiPriceFeed.setLatestAnswer(1 * 10 ** 8); // $1
        btcPriceFeed.setLatestAnswer(60000 * 10 ** 8); // $60,000
        bnbPriceFeed.setLatestAnswer(300 * 10 ** 8); // $300

        // Set GLP configuration
        glp.setInPrivateTransferMode(true);
        glp.setMinter(address(glpManager), true);
        glpManager.setInPrivateMode(true);
    }

    // STEP 3: Deploy reward tokens
    function step3_deployRewardTokens() public {
        gmx = new GMX();
        esGmx = new EsGMX();
        bnGmx = new MintableBaseToken("Bonus GMX", "bnGMX", 0);
    }
    // Add after deployRewardTokens function:
    function step4_setupGmxRewards() public {
        // Deploy GMX reward system
        stakedGmxTracker = new RewardTracker("Staked GMX", "sGMX");
        stakedGmxDistributor = new RewardDistributor(
            address(esGmx),
            address(stakedGmxTracker)
        );

        address[] memory stakedTokens = new address[](2);
        stakedTokens[0] = address(gmx);
        stakedTokens[1] = address(esGmx);
        stakedGmxTracker.initialize(
            stakedTokens,
            address(stakedGmxDistributor)
        );
        stakedGmxDistributor.updateLastDistributionTime();

        // Setup bonus tracker
        bonusGmxTracker = new RewardTracker("Staked + Bonus GMX", "sbGMX");
        bonusGmxDistributor = new BonusDistributor(
            address(bnGmx),
            address(bonusGmxTracker)
        );

        address[] memory bonusTokens = new address[](1);
        bonusTokens[0] = address(stakedGmxTracker);
        bonusGmxTracker.initialize(bonusTokens, address(bonusGmxDistributor));
        bonusGmxDistributor.updateLastDistributionTime();

        // Setup fee tracker
        feeGmxTracker = new RewardTracker("Staked + Bonus + Fee GMX", "sbfGMX");
        feeGmxDistributor = new RewardDistributor(
            address(eth),
            address(feeGmxTracker)
        );

        address[] memory feeTokens = new address[](1);
        feeTokens[0] = address(extendedGmxTracker); // Changed from bonusGmxTracker in V2
        feeGmxTracker.initialize(feeTokens, address(feeGmxDistributor));
        feeGmxDistributor.updateLastDistributionTime();
    }

    // STEP 5: Deploy and initialize GLP reward system
    function step5_setupGlpRewards() public {
        // Setup fee GLP tracker
        feeGlpTracker = new RewardTracker("Fee GLP", "fGLP");
        feeGlpDistributor = new RewardDistributor(
            address(eth),
            address(feeGlpTracker)
        );

        address[] memory feeGlpTokens = new address[](1);
        feeGlpTokens[0] = address(glp);
        feeGlpTracker.initialize(feeGlpTokens, address(feeGlpDistributor));
        feeGlpDistributor.updateLastDistributionTime();

        // Setup staked GLP tracker
        stakedGlpTracker = new RewardTracker("Fee + Staked GLP", "fsGLP");
        stakedGlpDistributor = new RewardDistributor(
            address(esGmx),
            address(stakedGlpTracker)
        );

        address[] memory stakedGlpTokens = new address[](1);
        stakedGlpTokens[0] = address(feeGlpTracker);
        stakedGlpTracker.initialize(
            stakedGlpTokens,
            address(stakedGlpDistributor)
        );
        stakedGlpDistributor.updateLastDistributionTime();

        // Set private transfer and staking modes
        stakedGmxTracker.setInPrivateTransferMode(true);
        stakedGmxTracker.setInPrivateStakingMode(true);
        bonusGmxTracker.setInPrivateTransferMode(true);
        bonusGmxTracker.setInPrivateStakingMode(true);
        bonusGmxTracker.setInPrivateClaimingMode(true);
        feeGmxTracker.setInPrivateTransferMode(true);
        feeGmxTracker.setInPrivateStakingMode(true);

        feeGlpTracker.setInPrivateTransferMode(true);
        feeGlpTracker.setInPrivateStakingMode(true);
        stakedGlpTracker.setInPrivateTransferMode(true);
        stakedGlpTracker.setInPrivateStakingMode(true);
    }

    function step6_setupExtendedRewards() public {
        // Deploy and initialize ExtendedGmxTracker
        extendedGmxTracker = new RewardTracker("ExtendedGmxTracker", "sbeGMX");
        extendedGmxDistributor = new RewardDistributor(
            address(gmx),
            address(extendedGmxTracker)
        );

        address[] memory depositTokens = new address[](1);
        depositTokens[0] = address(bonusGmxTracker);
        extendedGmxTracker.initialize(
            depositTokens,
            address(extendedGmxDistributor)
        );
        extendedGmxDistributor.updateLastDistributionTime();
        extendedGmxDistributor.setTokensPerInterval(1e16); // 0.01 per second

        // Configure FeeGmxTracker to accept ExtendedGmxTracker
        feeGmxTracker.setDepositToken(address(extendedGmxTracker), true);
    }

    function step7_setupNewRewardRouter() public {
        // Set up vesting
        gmxVester = new Vester(
            "Vested GMX",
            "vGMX",
            vestingDuration,
            address(esGmx),
            address(feeGmxTracker),
            address(gmx),
            address(stakedGmxTracker)
        );

        glpVester = new Vester(
            "Vested GLP",
            "vGLP",
            vestingDuration,
            address(esGmx),
            address(stakedGlpTracker),
            address(gmx),
            address(stakedGlpTracker)
        );

        // Set handlers for vesters
        gmxVester.setHandler(address(rewardRouterV2), true);
        glpVester.setHandler(address(rewardRouterV2), true);

        // Deploy RewardRouterV2 with mock external handler
        mockExternalHandler = new MockExternalHandler();
        // Deploy new RewardRouterV2
        rewardRouterV2 = new RewardRouterV2();

        RewardRouterV2.InitializeParams memory params = RewardRouterV2
            .InitializeParams({
                weth: address(bnb),
                gmx: address(gmx),
                esGmx: address(esGmx),
                bnGmx: address(bnGmx),
                glp: address(glp),
                stakedGmxTracker: address(stakedGmxTracker),
                bonusGmxTracker: address(bonusGmxTracker),
                extendedGmxTracker: address(extendedGmxTracker),
                feeGmxTracker: address(feeGmxTracker),
                feeGlpTracker: address(feeGlpTracker),
                stakedGlpTracker: address(stakedGlpTracker),
                glpManager: address(glpManager),
                gmxVester: address(gmxVester),
                glpVester: address(glpVester),
                externalHandler: address(mockExternalHandler),
                govToken: address(govToken)
            });

        // Set max boost basis points
        rewardRouterV2.initialize(params);

        rewardRouterV2.setMaxBoostBasisPoints(100);
        rewardRouterV2.setVotingPowerType(RewardRouterV2.VotingPowerType(1)); // Assuming enum value 1

        stakedGmxTracker.setHandler(address(rewardRouterV2), true);
        bonusGmxTracker.setHandler(address(rewardRouterV2), true);
        extendedGmxTracker.setHandler(address(rewardRouterV2), true);
        feeGmxTracker.setHandler(address(rewardRouterV2), true);
        feeGlpTracker.setHandler(address(rewardRouterV2), true);
        stakedGlpTracker.setHandler(address(rewardRouterV2), true);

        // Set handlers for trackers
        bonusGmxTracker.setHandler(address(extendedGmxTracker), true);
        bnGmx.setHandler(address(extendedGmxTracker), true);
        extendedGmxTracker.setHandler(address(feeGmxTracker), true);
        // Set GlpManager handler
        glpManager.setHandler(address(rewardRouterV2), true);

        gmx.setHandler(address(stakedGmxTracker), true);
        esGmx.setHandler(address(stakedGmxTracker), true);
        glp.setHandler(address(feeGlpTracker), true);

        extendedGmxTracker.setHandler(address(bonusGmxTracker), true); // Instead of the reverse
        extendedGmxTracker.setHandler(address(bnGmx), true); // Instead of the reverse

        // Reward trackers need handlers for RewardRouterV2 AND each other
        stakedGmxTracker.setHandler(address(bonusGmxTracker), true);
        bonusGmxTracker.setHandler(address(extendedGmxTracker), true);
        extendedGmxTracker.setHandler(address(feeGmxTracker), true);
        feeGmxTracker.setHandler(address(stakedGlpTracker), true);
        feeGlpTracker.setHandler(address(stakedGlpTracker), true);

        // Tokens need handlers for their respective trackers
        gmx.setHandler(address(rewardRouterV2), true); // For stake/unstake
        esGmx.setHandler(address(rewardRouterV2), true); // For rewards claiming
        glp.setHandler(address(rewardRouterV2), true); // For GLP operations

        // Set deposit tokens
        extendedGmxTracker.setDepositToken(address(bonusGmxTracker), true);
        extendedGmxTracker.setDepositToken(address(bnGmx), true);
        feeGmxTracker.setDepositToken(address(extendedGmxTracker), true);

        gmx.setMinter(owner, true);
        gmx.setMinter(address(rewardRouterV2), true);
        esGmx.setMinter(owner, true);
        esGmx.setMinter(address(rewardRouterV2), true);
        govToken.setMinter(address(rewardRouterV2), true);
    }

    function step8_approvals() public {
        // All possible approvals between all trackers

        // stakedGmxTracker approvals to all others
        vm.prank(user1);
        stakedGmxTracker.approve(address(bonusGmxTracker), type(uint256).max);

        vm.prank(user1);
        stakedGmxTracker.approve(
            address(extendedGmxTracker),
            type(uint256).max
        );

        vm.prank(user1);
        stakedGmxTracker.approve(address(feeGmxTracker), type(uint256).max);

        vm.prank(user1);
        stakedGmxTracker.approve(address(feeGlpTracker), type(uint256).max);

        vm.prank(user1);
        stakedGmxTracker.approve(address(stakedGlpTracker), type(uint256).max);

        // bonusGmxTracker approvals to all others
        vm.prank(user1);
        bonusGmxTracker.approve(address(extendedGmxTracker), type(uint256).max);

        vm.prank(user1);
        bonusGmxTracker.approve(address(feeGmxTracker), type(uint256).max);

        vm.prank(user1);
        bonusGmxTracker.approve(address(feeGlpTracker), type(uint256).max);

        vm.prank(user1);
        bonusGmxTracker.approve(address(stakedGlpTracker), type(uint256).max);

        vm.prank(user1);
        bonusGmxTracker.approve(address(stakedGmxTracker), type(uint256).max);

        // extendedGmxTracker approvals to all others
        vm.prank(user1);
        extendedGmxTracker.approve(address(bonusGmxTracker), type(uint256).max);

        vm.prank(user1);
        extendedGmxTracker.approve(address(feeGmxTracker), type(uint256).max);

        vm.prank(user1);
        extendedGmxTracker.approve(address(feeGlpTracker), type(uint256).max);

        vm.prank(user1);
        extendedGmxTracker.approve(
            address(stakedGlpTracker),
            type(uint256).max
        );

        vm.prank(user1);
        extendedGmxTracker.approve(
            address(stakedGmxTracker),
            type(uint256).max
        );

        // feeGmxTracker approvals to all others
        vm.prank(user1);
        feeGmxTracker.approve(address(bonusGmxTracker), type(uint256).max);

        vm.prank(user1);
        feeGmxTracker.approve(address(extendedGmxTracker), type(uint256).max);

        vm.prank(user1);
        feeGmxTracker.approve(address(feeGlpTracker), type(uint256).max);

        vm.prank(user1);
        feeGmxTracker.approve(address(stakedGlpTracker), type(uint256).max);

        vm.prank(user1);
        feeGmxTracker.approve(address(stakedGmxTracker), type(uint256).max);

        // feeGlpTracker approvals to all others
        vm.prank(user1);
        feeGlpTracker.approve(address(bonusGmxTracker), type(uint256).max);

        vm.prank(user1);
        feeGlpTracker.approve(address(extendedGmxTracker), type(uint256).max);

        vm.prank(user1);
        feeGlpTracker.approve(address(feeGmxTracker), type(uint256).max);

        vm.prank(user1);
        feeGlpTracker.approve(address(stakedGlpTracker), type(uint256).max);

        vm.prank(user1);
        feeGlpTracker.approve(address(stakedGmxTracker), type(uint256).max);

        // stakedGlpTracker approvals to all others
        vm.prank(user1);
        stakedGlpTracker.approve(address(bonusGmxTracker), type(uint256).max);

        vm.prank(user1);
        stakedGlpTracker.approve(
            address(extendedGmxTracker),
            type(uint256).max
        );

        vm.prank(user1);
        stakedGlpTracker.approve(address(feeGmxTracker), type(uint256).max);

        vm.prank(user1);
        stakedGlpTracker.approve(address(feeGlpTracker), type(uint256).max);

        vm.prank(user1);
        stakedGlpTracker.approve(address(stakedGmxTracker), type(uint256).max);

        // extendedGmxTracker approvals to all others
        vm.prank(user1);
        extendedGmxTracker.approve(address(bonusGmxTracker), type(uint256).max);

        vm.prank(user1);
        extendedGmxTracker.approve(address(feeGmxTracker), type(uint256).max);

        vm.prank(user1);
        extendedGmxTracker.approve(address(feeGlpTracker), type(uint256).max);

        vm.prank(user1);
        extendedGmxTracker.approve(
            address(stakedGlpTracker),
            type(uint256).max
        );

        vm.prank(user1);
        extendedGmxTracker.approve(
            address(stakedGmxTracker),
            type(uint256).max
        );
    }
}
