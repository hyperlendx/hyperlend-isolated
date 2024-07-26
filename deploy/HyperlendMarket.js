const { ethers } = require("hardhat");
const fs = require("fs")

async function main() {
    const accounts = await hre.ethers.getSigners();
    const lastDeployement = JSON.parse(fs.readFileSync("./deploy/deployments/HyperlendCore-deployment-data.json", "utf-8"))

    const HyperlendWhitelist = await ethers.getContractFactory("HyperlendWhitelist");
    const hyperlendWhitelist = HyperlendWhitelist.attach(lastDeployement.hyperlendWhitelist);

    const HyperlendPairRegistry = await ethers.getContractFactory("HyperlendPairRegistry");
    const hyperlendPairRegistry = HyperlendPairRegistry.attach(lastDeployement.hyperlendPairRegistry);

    const HyperlendPairDeployer = await ethers.getContractFactory("HyperlendPairDeployer");
    const hyperlendPairDeployer = HyperlendPairDeployer.attach(lastDeployement.hyperlendPairDeployer)

    //deploy first market
    const MockToken = await ethers.getContractFactory("MockERC20");
    const usdc = await MockToken.deploy("USDC", "USDC", 8)
    await usdc.deployed()
    const dai = await MockToken.deploy("DAI", "DAI", 8)
    await dai.deployed()

    const InterestRate = await ethers.getContractFactory("VariableInterestRate")
    const interestRate = await InterestRate.deploy(
        "[0.5 0.2@.875 5-10k] 2 days (.75-.85)",
        "87500",
        "200000000000000000",
        "75000",
        "85000",
        "158247046",
        "1582470460",
        "3164940920000",
        "172800"
    )
    await interestRate.deployed()

    const MockOracle = await ethers.getContractFactory("MockOracle")
    const mockOracle = await MockOracle.deploy()
    await mockOracle.deployed()

    const marketConfig = {
        asset: usdc.address,
        collateral: dai.address,
        oracle: mockOracle.address,
        maxOracleDeviation: "5000", //5%
        rateContract: interestRate.address,
        fullUtilizationRate: "9500000000",
        maxLTV: "75000", //75%
        cleanLiquidationFee: "10000", //10%
        dirtyLiquidationFee: "10000",
        protocolLiquidationFee: "10000"
    }
    const configData = ethers.utils.defaultAbiCoder.encode(
        [
            'address',
            'address',
            'address',
            'uint32',
            'address',
            'uint64',
            'uint256',
            'uint256',
            'uint256',
            'uint256'
        ],
        [
            marketConfig.asset,
            marketConfig.collateral,
            marketConfig.oracle,
            marketConfig.maxOracleDeviation,
            marketConfig.rateContract,
            marketConfig.fullUtilizationRate,
            marketConfig.maxLTV,
            marketConfig.cleanLiquidationFee,
            marketConfig.dirtyLiquidationFee,
            marketConfig.protocolLiquidationFee
        ]
    );
    await hyperlendPairDeployer.deploy(configData)

    let allMarkets = await hyperlendPairDeployer.getAllPairAddresses()
    const deploymentData = {
        marketAddress: allMarkets[allMarkets.length - 1],
        ...marketConfig,
    }
    fs.writeFileSync(`./deploy/deployments/HyperlendMarket-deployment-data.json`, JSON.stringify(deploymentData, null, 4))
    console.log(`Market with asset ${marketConfig.asset} and collateral ${marketConfig.collateral} deployed successfully!`)
}

module.exports.main = main

// main()
//     .then(() => process.exit(0))
//     .catch((error) => {
//     console.error(error);
//     process.exit(1);
// });