// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

/// @title HyperlendPairConstants
/// @notice An abstract contract which contains the errors and constants for the HyperlendPair contract
abstract contract HyperlendPairConstants {
    // ============================================================================================
    // Constants
    // ============================================================================================

    // Precision settings
    uint256 public constant LTV_PRECISION = 1e5; // 5 decimals
    uint256 public constant LIQ_PRECISION = 1e5;
    uint256 public constant UTIL_PREC = 1e5;
    uint256 public constant FEE_PRECISION = 1e5;
    uint256 public constant EXCHANGE_PRECISION = 1e18;
    uint256 public constant DEVIATION_PRECISION = 1e5;
    uint256 public constant RATE_PRECISION = 1e18;

    // Protocol Fee
    uint256 public constant MAX_PROTOCOL_FEE = 5e4; // 50% 1e5 precision

    error Insolvent(uint256 _borrow, uint256 _collateral, uint256 _exchangeRate);
    error BorrowerSolvent();
    error InsufficientAssetsInContract(uint256 _assets, uint256 _request);
    error SlippageTooHigh(uint256 _minOut, uint256 _actual);
    error BadSwapper();
    error InvalidPath(address _expected, address _actual);
    error BadProtocolFee();
    error PastDeadline(uint256 _blockTimestamp, uint256 _deadline);
    error SetterRevoked();
    error ExceedsMaxOracleDeviation();
    error InvalidReceiver();
}
