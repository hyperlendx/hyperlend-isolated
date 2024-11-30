// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ERC20 } from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import { IHyperlendPair } from '../interfaces/IHyperlendPair.sol';
import { IHyperlendPairRegistry } from '../interfaces/IHyperlendPairRegistry.sol';

import { HyperlendPairDeployer } from '../HyperlendPairDeployer.sol';
import { Ownable2Step } from '@openzeppelin/contracts/access/Ownable2Step.sol';

/// @title ListingsConfigEngine
/// @author HyperLend
/// @notice Contract used to seed new pairs after deployment
contract ListingsConfigEngine is Ownable2Step {
    constructor() Ownable2Step() {}

    /// @notice used to deploy new pairs
    /// @param _pairDeployer address of the HyperlendPairDeployer contract
    /// @param _asset address of the asset in the new pair
    /// @param _collateral address of the collateral in the new pair
    /// @param _assetAmount amount of the asset to deposit
    /// @param _collateralAmount amount of the collateral to deposit
    /// @param _configData data used to create new pair (see HyperlendPairDeployer:deploy)
    function deployPair(
        HyperlendPairDeployer _pairDeployer, 
        ERC20 _asset, 
        ERC20 _collateral, 
        uint256 _assetAmount, 
        uint256 _collateralAmount, 
        bytes memory _configData
    ) external onlyOwner(){
        IHyperlendPairRegistry pairRegistry = IHyperlendPairRegistry(_pairDeployer.hyperlendPairRegistryAddress());

        //deploy new pair contract
        _pairDeployer.deploy(_configData);

        //get address of the new pair contract
        uint256 newPairIndex = pairRegistry.deployedPairsLength();
        IHyperlendPair newPairAddress = IHyperlendPair(pairRegistry.deployedPairsArray(newPairIndex - 1));

        //transfer seed amounts from msg.sender
        _asset.transferFrom(msg.sender, address(this), _assetAmount);
        _collateral.transferFrom(msg.sender, address(this), _collateralAmount);

        //approve pair to spend seed amounts
        _asset.approve(address(newPairAddress), _assetAmount);
        _collateral.approve(address(newPairAddress), _collateralAmount);

        //deposit asset and add collateral
        newPairAddress.deposit(_assetAmount, msg.sender);
        newPairAddress.addCollateral(_collateralAmount, msg.sender);
    }
}
