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
    fs.writeFileSync(`./deploy/deployments/HyperlendCore-deployment-data.json`, JSON.stringify(deploymentData, null, 4))
    console.log(`HyperlendCore deployed successfully!`)
}

module.exports.main = main

// main()
//     .then(() => process.exit(0))
//     .catch((error) => {
//     console.error(error);
//     process.exit(1);
// });