const { ethers } = require("hardhat");

async function main({
    baseToken,
    quoteToken,
    chainlinkMultiplyAddress,
    chainlinkDivideAddress,
    maxOracleDelay,
    timelockAddress,
    name
}) {
    const Oracle = await ethers.getContractFactory("OracleChainLink");
    const oracle = await Oracle.deploy(
        baseToken,
        quoteToken,
        chainlinkMultiplyAddress,
        chainlinkDivideAddress,
        maxOracleDelay,
        timelockAddress,
        name
    )

    // console.log(`Oracle contract deployed to ${oracle.target}`)

    return {
        oracle: oracle
    }
}

module.exports.main = main