// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

/// @title HyperlendPairAccessControlErrors
/// @notice An abstract contract which contains the errors for the Access Control contract
abstract contract HyperlendPairAccessControlErrors {
    error OnlyProtocolOrOwner();
    error OnlyTimelockOrOwner();
    error ExceedsBorrowLimit();
    error AccessControlRevoked();
    error RepayPaused();
    error ExceedsDepositLimit();
    error WithdrawPaused();
    error LiquidatePaused();
    error InterestPaused();
}
