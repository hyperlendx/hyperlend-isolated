// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

import {Ownable2Step} from '@openzeppelin/contracts/access/Ownable2Step.sol';

contract HyperlendWhitelist is Ownable2Step {
    /// @notice Hyperlend Deployer Whitelist mapping.
    mapping(address => bool) public hyperlendDeployerWhitelist;

    constructor() Ownable2Step() {}

    /// @notice The ```SetHyperlendDeployerWhitelist``` event fires whenever a status is set for a given address.
    /// @param _address address being set.
    /// @param _bool approval being set.
    event SetHyperlendDeployerWhitelist(address indexed _address, bool _bool);

    /// @notice The ```setHyperlendDeployerWhitelist``` function sets a given address to true/false for use as a custom deployer.
    /// @param _addresses addresses to set status for.
    /// @param _bool status of approval.
    function setHyperlendDeployerWhitelist(
        address[] calldata _addresses,
        bool _bool
    ) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            hyperlendDeployerWhitelist[_addresses[i]] = _bool;
            emit SetHyperlendDeployerWhitelist(_addresses[i], _bool);
        }
    }
}
