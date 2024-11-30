const { ethers } = require("hardhat");

const { verify } = require("../utils/verify")

async function main({
    suffix, //name of the rate contract
    vertexUtilization, //The utilization at which the slope increases
    vertexRatePercentOfDelta, //The percent of the delta between max and min, in 1e18
    minUtil, //minimum utilization wherein no adjustment to full utilization and vertex rates occurs
    maxUtil, //maximum utilization wherein no adjustment to full utilization and vertex rates occurs
    zeroUtilizationRate, //interest rate (per second) when utilization is 0%
    minFullUtilizationRate, //minimum interest rate (per second) when utilization is 100%
    maxFullUtilizationRate, //max interest rate (per second) when utilization is 100%
    rateHalfLife //interest rate half life in seconds
}) {
    const VariableInterestRate = await ethers.getContractFactory("VariableInterestRate");
    const interestRate = await VariableInterestRate.deploy(
        suffix,
        vertexUtilization,
        vertexRatePercentOfDelta,
        minUtil,
        maxUtil,
        zeroUtilizationRate,
        minFullUtilizationRate,
        maxFullUtilizationRate,
        rateHalfLife
    )

    await verify(interestRate.target, [
        suffix,
        vertexUtilization,
        vertexRatePercentOfDelta,
        minUtil,
        maxUtil,
        zeroUtilizationRate,
        minFullUtilizationRate,
        maxFullUtilizationRate,
        rateHalfLife
    ], null, {
        verificationDataDir: null, verificationDataPath: null
    })

    // console.log(`VariableInterestRate contract deployed to ${interestRate.target}`)

    return {
        interestRate: interestRate
    }
}

module.exports.main = main