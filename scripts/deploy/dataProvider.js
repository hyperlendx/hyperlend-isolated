const { ethers } = require("hardhat");
const fs = require("fs")
const path = require("path")

const { verify } = require("../utils/verify")

main()

async function main() {
    const [deployer, admin, borrower, lender] = await hre.ethers.getSigners();

    const DataProvider = await ethers.getContractFactory("UiDataProviderIsolated");
    const dataProvider = await DataProvider.deploy()

    await verify(dataProvider.target, [], null, {
        verificationDataDir: null, verificationDataPath: null
    })
}

