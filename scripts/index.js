const deployCoreScript = require("./deploy/core")
const deployPairScript = require("./deploy/pair")
const deployInterestRateScript = require("./deploy/interestRate")
const deployOracleScript = require("./deploy/oracle")

main()

async function main(){
    console.log(await deployCoreScript.main())

    const oracleConfig = {
        baseToken: "0x4D6b8f9518b0b92080b5eAAf80bD505734A059Ae", //asset TESTH
        quoteToken: "0xe0bdd7e8b7bf5b15dcDA6103FCbBA82a460ae2C7", //collateral
        chainlinkMultiplyAddress: '0x713c630Cbb3A37b45bA3921125abb3D0D4F4d8ef', //TESTH provider
        chainlinkDivideAddress: '0xdF6CeC37cF3EB6c69146A0787f8488B94ef3c22E', //WETH provider
        maxOracleDelay: "1000000",
        timelockAddress: "0x7aD41C2D642Ba3AdC42CdC06eE1860aaB7DCF4d6",
        name: "ChainlinkSingle-TESH-WETH"
    }
    let { oracle } = await deployOracleScript.main(oracleConfig)
    console.log(oracle)
    console.log(await oracle.getPrices())
    console.log(await oracle.decimals())

    const interestRateConfig = {
        suffix: "1-10-100 | 1 day | 50%-85% | 90%", //zeroUtil-minFullUtil-maxFullUtil | half life | minUtil-maxUtil | vertexUtil
        vertexUtilization: "90000", //90%
        vertexRatePercentOfDelta: "200000000000000000",
        minUtil: "50000", //50%
        maxUtil: "85000", //85%
        zeroUtilizationRate: "318900000", //~1% APR
        minFullUtilizationRate: "3189000000", //~10%
        maxFullUtilizationRate: "31890000000", //~100% APR
        rateHalfLife: "86400" //1 day
    }
    let interestRate = await deployInterestRateScript.main(interestRateConfig)
    console.log(interestRate)

    let pairConfig = {
        hyperlendPairRegistry: "0xB6aE067434D36684006b4561328eF4fA8016ee22",
        hyperlendPairDeployerAddress: "0x3b4537eE82e3d6361a3D57744e64D02f3E0C2B7c",
        assetTokenAddress: "0x4D6b8f9518b0b92080b5eAAf80bD505734A059Ae", //borrow TESTH
        collateralTokenAddress: "0xe0bdd7e8b7bf5b15dcDA6103FCbBA82a460ae2C7", //supply WETH as collateral
        interestRateAddress: "0x6B722a79DF53c7fFc74aA0438c8249abdE025E8a",
        oracleAddress: "0x830FD4c57d26a4604deeb002e3f8B2f8c06382F0",
        maxOracleDeviation: "5000", //5%
        fullUtilizationRate: "9500000000", //~30% start APR
        maxLTV: "75000", //75%
        cleanLiquidationFee: "10000", //10%
        protocolLiquidationFee: "10000" //10% of the liquidator's fee
    }
    console.log(await deployPairScript.main(pairConfig))
}