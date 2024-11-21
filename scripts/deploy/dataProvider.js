const { ethers } = require("hardhat");
const fs = require("fs")
const path = require("path")

main()

async function main() {
    const [deployer, admin, borrower, lender] = await hre.ethers.getSigners();

    const DataProvider = await ethers.getContractFactory("UiDataProviderIsolated");
    const dataProvider = await DataProvider.deploy()

    console.log(dataProvider)

    console.log(await dataProvider.getPairData('0xB1ed098b6b7Ae18b0Aa822c90a1E0371c7fDb96D'))
}

