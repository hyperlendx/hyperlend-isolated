const { ethers } = require("hardhat");
const fs = require("fs")

async function main() {
    const accounts = await hre.ethers.getSigners();

    const constructorParams = {
        circuitBreaker: "0x0000000000000000000000000000000000000024",
        comptroller: "0x0000000000000000000000000000000000000024",
        timelock: "0x0000000000000000000000000000000000000024",
    }
    
    const ownerAddress = accounts[0].address
    const initialDeployers = [accounts[0].address, "0x0000000000000000000000000000000000000025"]

    const HyperlendWhitelist = await ethers.getContractFactory("HyperlendWhitelist");
    const hyperlendWhitelist = await HyperlendWhitelist.deploy();
    await hyperlendWhitelist.deployed();
    await hyperlendWhitelist.setHyperlendDeployerWhitelist([accounts[0].address], [true])
    console.log(`HyperlendWhitelist deployed to ${hyperlendWhitelist.address}`)

    const HyperlendPairRegistry = await ethers.getContractFactory("HyperlendPairRegistry");
    const hyperlendPairRegistry = await HyperlendPairRegistry.deploy(ownerAddress, initialDeployers);
    await hyperlendPairRegistry.deployed();
    console.log(`HyperlendPairRegistry deployed to ${hyperlendPairRegistry.address}`)

    const HyperlendPairDeployer = await ethers.getContractFactory("HyperlendPairDeployer");
    const hyperlendPairDeployerParams = {
        circuitBreaker: constructorParams.circuitBreaker,
        comptroller: constructorParams.timelock,
        timelock: constructorParams.timelock,
        hyperlendWhitelist: hyperlendWhitelist.address,
        hyperlendPairRegistry: hyperlendPairRegistry.address
    }
    const hyperlendPairDeployer = await HyperlendPairDeployer.deploy(hyperlendPairDeployerParams);
    await hyperlendPairDeployer.deployed();
    console.log(`HyperlendPairDeployer deployed to ${hyperlendPairDeployer.address}`)

    //set deployer contract as deployer in pairRegistry
    await hyperlendPairRegistry.setDeployers([hyperlendPairDeployer.address], [true])

    //set pair creation code
    const pairArtifacts = JSON.parse(fs.readFileSync("./artifacts/src/contracts/HyperlendPair.sol/HyperlendPair.json"))
    await hyperlendPairDeployer.setCreationCode(pairArtifacts.bytecode)
    console.log(`HyperlendPair creation code set`)

    const deploymentData = {
        hyperlendWhitelist: hyperlendWhitelist.address,
        hyperlendPairRegistry: hyperlendPairRegistry.address,
        hyperlendPairDeployer: hyperlendPairDeployer.address,
        params: {
            hyperlendPairRegistry: {
                owner: ownerAddress,
                initialDeployers: initialDeployers
            },
            hyperlendPairDeployer: hyperlendPairDeployerParams
        }
    }
    fs.writeFileSync(`./deploy/deployments/deployment-data-${new Date().getTime()}.json`, JSON.stringify(deploymentData, null, 4))
    console.log(`HyperlendCore deployed successfully!`)

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
    console.log(`Market with asset ${marketConfig.asset} and collateral ${marketConfig.collateral} deployed`)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
    console.error(error);
    process.exit(1);
});