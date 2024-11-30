const { ethers } = require("hardhat");

const { verify } = require("../utils/verify")

async function main({
    baseToken,
    quoteToken,
    chainlinkMultiplyAddress,
    chainlinkDivideAddress,
    maxOracleDelay,
    timelockAddress,
    name
}) {
    const Oracle = await ethers.getContractFactory("OracleChainlink");
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

    await verify(oracle.target, [
        baseToken,
        quoteToken,
        chainlinkMultiplyAddress,
        chainlinkDivideAddress,
        maxOracleDelay,
        timelockAddress,
        name
    ], null, {
        verificationDataDir: null, verificationDataPath: null
    })

    return {
        oracle: oracle
    }
}

module.exports.main = main