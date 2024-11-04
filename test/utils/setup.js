const deployCoreScript = require("../../scripts/deploy/core")
const deployPairScript = require("../../scripts/deploy/pair")
const deployInterestRateScript = require("../../scripts/deploy/interestRate")
const deployOracleScript = require("../../scripts/deploy/oracle")

const deployMockTokensScript = require("../../scripts/mocks/mockTokens")
const deployMockOracleScript = require("../../scripts/mocks/mockChainlinkOracle")

async function deployCore() {
    return await deployCoreScript.main()
}

async function deployPair(marketConfig){
    return await deployPairScript.main(marketConfig)
}

async function deployOracle(oracleConfig){
    return await deployOracleScript.main(oracleConfig)
}

async function deployInterestRate(interestRateConfig){
    return await deployInterestRateScript.main(interestRateConfig)
}

async function deployMockTokens(names, symbols, decimals){
    return await deployMockTokensScript.main(names, symbols, decimals);
}

async function deployMockChainlinkOracle(price){
    return await deployMockOracleScript.main(price)
}

module.exports.deployCore = deployCore
module.exports.deployPair = deployPair
module.exports.deployOracle = deployOracle
module.exports.deployInterestRate = deployInterestRate

module.exports.deployMockTokens = deployMockTokens
module.exports.deployMockChainlinkOracle = deployMockChainlinkOracle