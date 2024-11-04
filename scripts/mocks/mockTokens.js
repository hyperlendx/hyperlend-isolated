const { ethers } = require("hardhat");

async function main(symbols, decimals) {
    let deployedTokens = {}
    
    for (let i in symbols){
        const MockToken = await ethers.getContractFactory("MockERC20");
        const mockToken = await MockToken.deploy(symbols[i], symbols[i], decimals[i])
    
        // console.log(`Mock token ${symbols[i]} contract deployed to ${mockToken.target}`)
        deployedTokens[symbols[i]] = mockToken
    }

    return {
        mockTokens: deployedTokens
    }
}

module.exports.main = main