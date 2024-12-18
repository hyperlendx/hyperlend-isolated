const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture, time } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

const setup = require("./utils/setup")

describe("BaseTest", function () {
    async function deployCore() {
        let deploymentInstancesCore = await setup.deployCore()

        const interestRateConfig = {
            suffix: "1-10-100 | 1 day | 50%-85% | 90%", //zeroUtil-minFullUtil-maxFullUtil | half life | minUtil-maxUtil | vertexUtil
            vertexUtilization: "90000", //90%
            vertexRatePercentOfDelta: "200000000000000000",
            minUtil: "50000", //50%
            maxUtil: "85000", //85%
            zeroUtilizationRate: "318900000", //~1% APR
            minFullUtilizationRate: "3189000000", //~10%
            maxFullUtilizationRate: "31890000000", //~100% APR
            rateHalfLife: "86400" //1 day
        }
        let deploymentInstanceInterestRate = await setup.deployInterestRate(interestRateConfig)

        let deploymentInstancesMockTokens = await setup.deployMockTokens(["USDC", "WETH"], [6, 18])

        let mockUsdcOracle = await setup.deployMockChainlinkOracle("100000000") //1 USD
        let mockWethOracle = await setup.deployMockChainlinkOracle("240000000000") //2400 USD

        const oracleConfig = {
            baseToken: deploymentInstancesMockTokens.mockTokens.WETH.target, //asset
            quoteToken: deploymentInstancesMockTokens.mockTokens.USDC.target, //collateral
            chainlinkMultiplyAddress: mockWethOracle.target,
            chainlinkDivideAddress: mockUsdcOracle.target,
            maxOracleDelay: "1000000",
            timelockAddress: deploymentInstancesCore.timelock.target,
            name: "MockChainlinkSingle"
        }
        let deploymentInstanceOracle = await setup.deployOracle(oracleConfig) //oracle returns amount of collateral to buy 1e18 of asset

        return { 
            //available contracts: timelock, hyperlendWhitelist, hyperlendPairRegistry, hyperlendPairDeployer; signers: depoyer, admin, borrower, lender
            ...deploymentInstancesCore, 
            //available contracts: interestRate
            ...deploymentInstanceInterestRate,
            //available contracts: oracle
            ...deploymentInstanceOracle,
            //available contracts: mockTokens: { symbol: contract }
            ...deploymentInstancesMockTokens
        }
    }

    async function deployPair(fixture){
        let pairConfig = {
            hyperlendPairRegistry: fixture.hyperlendPairRegistry.target,
            hyperlendPairDeployerAddress: fixture.hyperlendPairDeployer.target,
            assetTokenAddress: fixture.mockTokens.WETH.target, //borrow WETH
            collateralTokenAddress: fixture.mockTokens.USDC.target, //supply USDC as collateral
            interestRateAddress: fixture.interestRate.target,
            oracleAddress: fixture.oracle.target,
            maxOracleDeviation: "5000", //5%
            fullUtilizationRate: "9500000000", //~30% start APR
            maxLTV: "75000", //75%
            cleanLiquidationFee: "10000", //10%
            protocolLiquidationFee: "1000" //10% of the liquidator's fee
        }
        let pairAddress = await setup.deployPair(pairConfig)
        let pair = (await ethers.getContractFactory("HyperlendPair")).attach(pairAddress)

        return { pair }
    }

    it("should deploy an isolated pair", async function () {
        let data = await loadFixture(deployCore)
        let { pair } = await deployPair(data)

        expect(await pair.name()).to.equal("Hyperlend Interest Bearing WETH (USDC)")
        expect(await pair.asset()).to.equal(data.mockTokens.WETH.target)
    });

    it("should supply collateral", async function () {
        let data = await loadFixture(deployCore)
        let { pair } = await deployPair(data)

        await data.mockTokens.USDC.mint(data.lender, ethers.parseUnits("100", 6))
        await data.mockTokens.USDC.connect(data.lender).approve(pair.target, ethers.parseUnits("1000000000000000000", 18))
        await data.mockTokens.WETH.mint(data.lender, ethers.parseUnits("10", 18))
        await data.mockTokens.WETH.connect(data.lender).approve(pair.target, ethers.parseUnits("1000000000000000000", 18))

        //deposit asset (WETH)
        await pair.connect(data.lender).deposit(ethers.parseUnits("1", 18), data.lender.address)
        expect(await pair.balanceOf(data.lender.address)).to.equal(ethers.parseUnits("1", 18))

        //add collateral (USDC)
        await pair.connect(data.lender).addCollateral(ethers.parseUnits("100", 6), data.lender.address)
        expect(await pair.userCollateralBalance(data.lender.address)).to.equal(ethers.parseUnits("100", 6))

        //borrow asset (WETH)
        await pair.connect(data.lender).borrowAsset(ethers.parseUnits("0.01", 18), 0, data.lender.address)
        expect(await pair.userBorrowShares(data.lender.address)).to.equal(ethers.parseUnits("0.01", 18))

        //repay borrowed assets
        await pair.connect(data.lender).repayAsset(ethers.parseUnits("0.01", 18), data.lender.address)
        expect(await pair.userBorrowShares(data.lender.address)).to.equal(ethers.parseUnits("0", 18))

        //withdraw collateral
        await pair.connect(data.lender).removeCollateral(ethers.parseUnits("100", 6), data.lender.address)
        expect(await pair.userCollateralBalance(data.lender.address)).to.equal(ethers.parseUnits("0", 6))

        //redeem asset shares
        await pair.connect(data.lender).redeem((await pair.balanceOf(data.lender.address)), data.lender.address, data.lender.address)
        expect(await pair.balanceOf(data.lender.address)).to.equal(ethers.parseUnits("0", 18))

        expect(await data.mockTokens.USDC.balanceOf(data.lender.address)).to.equal(ethers.parseUnits("100", 6))
        expect(await data.mockTokens.WETH.balanceOf(data.lender.address)).to.equal(ethers.parseUnits("10", 18))
    });
});