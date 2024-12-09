// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ERC20 } from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import { HyperlendPair } from '../HyperlendPair.sol';
import { OracleChainlink } from '../oracles/OracleChainlink.sol';

contract UiDataProviderIsolated {
    struct InterestRateInfo {
        uint32 lastBlock;
        uint32 feeToProtocolRate;
        uint64 lastTimestamp;
        uint64 ratePerSec;
        uint64 fullUtilizationRate;
    }
    struct ExchangeRateInfo {
        address oracle;
        uint32 maxOracleDeviation;
        uint184 lastTimestamp;
        uint256 lowExchangeRate;
        uint256 highExchangeRate;
        address chainlinkAssetAddress;
        address chainlinkCollateralAddress;
    }
    struct PairData {
        address pair;
        address asset;
        address collateral;
        uint256 ltv;
        uint256 totalAsset;
        uint256 totalBorrow;
        uint256 totalCollateral;
        uint256 decimals;
        string name;
        string symbol;
        InterestRateInfo interestRate;
        ExchangeRateInfo exchangeRate;
        uint256 availableLiquidity;
    }

    struct UserData {
        address user;
        address pair;
        uint256 userAssets;
        uint256 userCollateral;
        uint256 userBorrow;
        uint256 maxWithdraw;
    }

    function getPairData(address _pair) external view returns (PairData memory pairData) {
        HyperlendPair pair = HyperlendPair(_pair);

        (uint128 totalAssetAmount, ) = pair.totalAsset();
        (uint128 totalBorrowAmount, ) = pair.totalBorrow();
        (
            uint32 lastBlock,
            uint32 feeToProtocolRate,
            uint64 lastTimestamp,
            uint64 ratePerSec,
            uint64 fullUtilizationRate
        ) = pair.currentRateInfo();
        (
            address oracle,
            uint32 maxOracleDeviation,
            uint184 lastTimestampExchRate,
            uint256 lowExchangeRate,
            uint256 highExchangeRate
        ) = pair.exchangeRateInfo();

        OracleChainlink oracleChainlink = OracleChainlink(oracle);

        return PairData({
            pair: _pair,
            asset: pair.asset(),
            collateral: pair.collateralContract(),
            ltv: pair.maxLTV(),
            totalAsset: totalAssetAmount,
            totalBorrow: totalBorrowAmount,
            totalCollateral: pair.totalCollateral(),
            decimals: pair.decimals(),
            name: pair.name(),
            symbol: pair.symbol(),
            interestRate: InterestRateInfo({
                lastBlock: lastBlock,
                feeToProtocolRate: feeToProtocolRate,
                lastTimestamp: lastTimestamp,
                ratePerSec: ratePerSec,
                fullUtilizationRate: fullUtilizationRate
            }),
            exchangeRate: ExchangeRateInfo({
                oracle: oracle,
                maxOracleDeviation: maxOracleDeviation,
                lastTimestamp: lastTimestampExchRate,
                lowExchangeRate: lowExchangeRate,
                highExchangeRate: highExchangeRate,
                chainlinkAssetAddress: oracleChainlink.CHAINLINK_MULTIPLY_ADDRESS(),
                chainlinkCollateralAddress: oracleChainlink.CHAINLINK_DIVIDE_ADDRESS()
            }),
            availableLiquidity: totalAssetAmount - totalBorrowAmount
        });
    }

    function getUserData(address _user, address _pair) external view returns (UserData memory) {
        HyperlendPair pair = HyperlendPair(_pair);

        (
            uint256 _userAssetShares,
            uint256 _userBorrowShares,
            uint256 _userCollateralBalance
        ) = pair.getUserSnapshot(_user);

        return UserData({
            user: _user,
            pair: _pair,
            userAssets: pair.toAssetAmount(_userAssetShares),
            userCollateral: _userCollateralBalance,
            userBorrow: pair.toBorrowAmount(_userBorrowShares),
            maxWithdraw: pair.maxWithdraw(_user)
        });
    }
}
