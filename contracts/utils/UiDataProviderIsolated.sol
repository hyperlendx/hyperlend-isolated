// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { IHyperlendPair } from '../interfaces/IHyperlendPair.sol';

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
    }

    function getPairData(address _pair) external view returns (PairData memory pairData) {
        IHyperlendPair pair = IHyperlendPair(_pair);

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
                highExchangeRate: highExchangeRate
            })
        });
    }
}