const deployCoreScript = require("./deploy/core")
const deployPairScript = require("./deploy/pair")
const deployInterestRateScript = require("./deploy/interestRate")
const deployOracleScript = require("./deploy/oracle")

const { verify } = require("./utils/verify")

main()

async function main(){
    // const [deployer, admin] = await hre.ethers.getSigners();

    // console.log(await deployCoreScript.main())

    // const oracleConfig = {
    //     baseToken: "0xe0bdd7e8b7bf5b15dcDA6103FCbBA82a460ae2C7", //asset WETH
    //     quoteToken: "0xe2FbC9cB335A65201FcDE55323aE0F4E8A96A616", //collateral
    //     chainlinkMultiplyAddress: '0xdF6CeC37cF3EB6c69146A0787f8488B94ef3c22E', //WETH provider
    //     chainlinkDivideAddress: '0x11CE4F650957e03f5a465839F7f699d19dB43c41', //collateral provider
    //     maxOracleDelay: "1000000",
    //     timelockAddress: "0x33e99304C3F628067Bb0939b21820d7Ba39913AB",
    //     name: "ChainlinkSingle-WETH-stHYPE"
    // }
    // let { oracle } = await deployOracleScript.main(oracleConfig)
    // console.log(oracle)
    // console.log(await oracle.getPrices())
    // console.log(await oracle.decimals())

    // const interestRateConfig = {
    //     suffix: "1-10-100 | 1 day | 50%-85% | 90%", //zeroUtil-minFullUtil-maxFullUtil | half life | minUtil-maxUtil | vertexUtil
    //     vertexUtilization: "90000", //90%
    //     vertexRatePercentOfDelta: "200000000000000000",
    //     minUtil: "50000", //50%
    //     maxUtil: "85000", //85%
    //     zeroUtilizationRate: "318900000", //~1% APR
    //     minFullUtilizationRate: "3189000000", //~10%
    //     maxFullUtilizationRate: "31890000000", //~100% APR
    //     rateHalfLife: "86400" //1 day
    // }
    // let interestRate = await deployInterestRateScript.main(interestRateConfig)
    // console.log(interestRate)

    // let pairConfig = {
    //     hyperlendPairRegistry: "0x274396Ec36D17dAbC018d9437D5a4C0D0fD503D0",
    //     hyperlendPairDeployerAddress: "0x0d17A8856aD18C5CCE4B426744Fee0d918c6a7D4",
    //     assetTokenAddress: "0xe0bdd7e8b7bf5b15dcDA6103FCbBA82a460ae2C7", //borrow WETH
    //     collateralTokenAddress: "0x453b63484b11bbF0b61fC7E854f8DAC7bdE7d458", //supply MBTC as collateral
    //     interestRateAddress: '0x339a57F0bc7ad67dC1956aE5254038AEae1cAe9B',
    //     oracleAddress: '0x58B5039fF60227db6dFf6186E57340fc7a853F84',
    //     maxOracleDeviation: "5000", //5%
    //     fullUtilizationRate: "9500000000", //~30% start APR
    //     maxLTV: "75000", //75%
    //     cleanLiquidationFee: "10000", //10%
    //     protocolLiquidationFee: "10000" //10% of the liquidator's fee
    // }
    // console.log(await deployPairScript.main(pairConfig))
}