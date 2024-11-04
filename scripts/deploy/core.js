const { ethers } = require("hardhat");
const fs = require("fs")
const path = require("path")

async function main() {
    const [deployer, admin, borrower, lender] = await hre.ethers.getSigners();

    // console.log(`-------- core contracts deployment started --------`)

    const Timelock = await ethers.getContractFactory("Timelock");
    const timelock = await Timelock.deploy(admin.address, 60 * 60 * 24 * 2)
    // console.log(`Timelock deployed to ${timelock.target}`)
    
    const HyperlendWhitelist = await ethers.getContractFactory("HyperlendWhitelist");
    const hyperlendWhitelist = await HyperlendWhitelist.deploy();
    await hyperlendWhitelist.setHyperlendDeployerWhitelist([deployer.address], [true])
    // console.log(`HyperlendWhitelist deployed to ${hyperlendWhitelist.target}`)

    const initialDeployers = [deployer.address, admin.address]
    const HyperlendPairRegistry = await ethers.getContractFactory("HyperlendPairRegistry");
    const hyperlendPairRegistry = await HyperlendPairRegistry.deploy(deployer.address, initialDeployers);
    // console.log(`HyperlendPairRegistry deployed to ${hyperlendPairRegistry.target}`)

    const constructorParams = {
        circuitBreaker: admin.address,
        comptroller: admin.address,
        timelock: timelock.target,
    }
    const HyperlendPairDeployer = await ethers.getContractFactory("HyperlendPairDeployer");
    const hyperlendPairDeployerParams = {
        circuitBreaker: constructorParams.circuitBreaker,
        comptroller: constructorParams.timelock,
        timelock: constructorParams.timelock,
        hyperlendWhitelist: hyperlendWhitelist.target,
        hyperlendPairRegistry: hyperlendPairRegistry.target
    }
    const hyperlendPairDeployer = await HyperlendPairDeployer.deploy(hyperlendPairDeployerParams);
    // console.log(`HyperlendPairDeployer deployed to ${hyperlendPairDeployer.target}`)

    //set deployer contract as deployer in pairRegistry
    await hyperlendPairRegistry.setDeployers([hyperlendPairDeployer.target], [true])

    //set pair creation code
    const pairArtifacts = JSON.parse(fs.readFileSync(path.join(__dirname + "../../../artifacts/contracts/HyperlendPair.sol/HyperlendPair.json")))
    await hyperlendPairDeployer.setCreationCode(pairArtifacts.bytecode)
    // console.log(`HyperlendPair creation code set`)

    const deploymentData = {
        hyperlendWhitelist: hyperlendWhitelist.target,
        hyperlendPairRegistry: hyperlendPairRegistry.target,
        hyperlendPairDeployer: hyperlendPairDeployer.target,
        params: {
            hyperlendPairRegistry: {
                owner: deployer.address,
                initialDeployers: initialDeployers
            },
            hyperlendPairDeployer: hyperlendPairDeployerParams
        },
        timelock: timelock.target
    }
    // console.log(`-------- core contracts deployment completed --------`)

    return {
        deployer: deployer, admin: admin, borrower: borrower, lender: lender,
        timelock: timelock,
        hyperlendWhitelist: hyperlendWhitelist,
        hyperlendPairRegistry: hyperlendPairRegistry,
        hyperlendPairDeployer: hyperlendPairDeployer,
        extra: deploymentData
    }
}

module.exports.main = main