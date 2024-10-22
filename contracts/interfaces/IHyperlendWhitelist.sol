// SPDX-License-Identifier: ISC
pragma solidity >=0.8.19;

interface IHyperlendWhitelist {
    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SetHyperlendDeployerWhitelist(address indexed _address, bool _bool);

    function acceptOwnership() external;

    function hyperlendDeployerWhitelist(address) external view returns (bool);

    function owner() external view returns (address);

    function pendingOwner() external view returns (address);

    function renounceOwnership() external;

    function setHyperlendDeployerWhitelist(address[] memory _addresses, bool _bool) external;

    function transferOwnership(address newOwner) external;
}
