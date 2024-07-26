// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

contract MockOracle {
    function getPrices() external pure returns (bool _isBadData, uint256 _priceLow, uint256 _priceHigh) {
        _isBadData = false;
        _priceLow = 382585585193105659;
        _priceHigh = 1383045369576038047;
    }
}