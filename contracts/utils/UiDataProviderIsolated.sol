// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ERC20 } from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import { IERC20Metadata } from '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import { HyperlendPair } from '../HyperlendPair.sol';
import { OracleChainlink } from '../oracles/OracleChainlink.sol';
import { HyperlendPairRegistry } from '../HyperlendPairRegistry.sol';

interface AggregatorInterface {
    function latestAnswer() external view returns (int256);
}

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
        uint8 decimals;
        uint256 userAssets;
        uint256 userCollateral;
        uint256 userBorrow;
        uint256 maxWithdraw;
        uint256 userAssetsShares;
        uint256 userBorrowShares;
    }

    struct UserPosition {
        address pair;
        address asset;
        address collateral;
        uint256 assetDecimals;
        uint256 collateralDecimals;
        uint256 suppliedAssets;
        uint256 borrowedAssets;
        uint256 suppliedShares;
        uint256 borrowedShares;
        uint256 suppliedCollateral;
        uint256 ratePerSec;
        uint256 utilization;
        uint256 feeToProtocolRate;
        int256 assetPrice;
        int256 collateralPrice;
    }

    uint256 public constant UTIL_PREC = 1e5;

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
            collateral: address(pair.collateralContract()),
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
            decimals: pair.decimals(),
            userAssets: pair.toAssetAmount(_userAssetShares, false, true),
            userCollateral: _userCollateralBalance,
            userBorrow: pair.toBorrowAmount(_userBorrowShares, false, true),
            userAssetsShares: _userAssetShares,
            userBorrowShares: _userBorrowShares,
            maxWithdraw: pair.maxWithdraw(_user)
        });
    }

    function getUserPairs(address _user, address _registry) external view returns (UserPosition[] memory){
        address[] memory pairs = HyperlendPairRegistry(_registry).getAllPairAddresses();

        UserPosition[] memory userPositions = new UserPosition[](pairs.length);
        for (uint256 i = 0; i < pairs.length; i++){
            HyperlendPair pair = HyperlendPair(pairs[i]);
            (
                uint256 userAssetShares,
                uint256 userBorrowShares,
                uint256 userCollateralBalance
            ) = pair.getUserSnapshot(_user);
            if (userAssetShares > 0 || userBorrowShares > 0 || userCollateralBalance > 0){
                (,uint256 feeToProtocolRate,,uint64 ratePerSec,) = pair.currentRateInfo();
                (uint128 borrowAmount,) = pair.totalBorrow();
                (uint128 assetAmount,) = pair.totalAsset();
                (address oracle,,,,) = pair.exchangeRateInfo();

                IERC20Metadata asset = IERC20Metadata(address(pair.asset()));
                IERC20Metadata collateral = IERC20Metadata(address(pair.collateralContract()));

                userPositions[i] = UserPosition({
                    pair: pairs[i],
                    asset: address(asset),
                    collateral: address(collateral),
                    assetDecimals: asset.decimals(),
                    collateralDecimals: collateral.decimals(),
                    suppliedAssets: pair.toAssetAmount(userAssetShares, false, true),
                    borrowedAssets: pair.toBorrowAmount(userBorrowShares, false, true),
                    suppliedShares: userAssetShares,
                    borrowedShares: userBorrowShares,
                    suppliedCollateral: userCollateralBalance,
                    ratePerSec: ratePerSec,
                    feeToProtocolRate: feeToProtocolRate,
                    utilization: assetAmount == 0 ? 0 : (UTIL_PREC * borrowAmount) / assetAmount,
                    assetPrice: AggregatorInterface(OracleChainlink(oracle).CHAINLINK_MULTIPLY_ADDRESS()).latestAnswer(),
                    collateralPrice: AggregatorInterface(OracleChainlink(oracle).CHAINLINK_DIVIDE_ADDRESS()).latestAnswer()
                });
            }
        }

        return userPositions;
    }
}
