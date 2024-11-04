const { ethers } = require("hardhat");

async function main(price) {
    const MockChainlinkOracle = await ethers.getContractFactory("MockChainlinkOracle");
    const mockOracle = await MockChainlinkOracle.deploy(price)

    // console.log(`Mock chainlink oracle contract deployed to ${mockOracle.target}`)

    return mockOracle
}

module.exports.main = main