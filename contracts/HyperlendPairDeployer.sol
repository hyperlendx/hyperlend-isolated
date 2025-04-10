// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {Strings} from '@openzeppelin/contracts/utils/Strings.sol';
import {SSTORE2} from '@rari-capital/solmate/src/utils/SSTORE2.sol';
import {BytesLib} from 'solidity-bytes-utils/contracts/BytesLib.sol';
import {IHyperlendWhitelist} from './interfaces/IHyperlendWhitelist.sol';
import {IHyperlendPair} from './interfaces/IHyperlendPair.sol';
import {IHyperlendPairRegistry} from './interfaces/IHyperlendPairRegistry.sol';
import {SafeERC20} from './libraries/SafeERC20.sol';

// solhint-disable no-inline-assembly

struct ConstructorParams {
    address circuitBreaker;
    address comptroller;
    address timelock;
    address hyperlendWhitelist;
    address hyperlendPairRegistry;
}

/// @title HyperlendPairDeployer
/// @notice Deploys and initializes new HyperlendPairs
/// @dev Uses create2 to deploy the pairs, logs an event, and records a list of all deployed pairs
contract HyperlendPairDeployer is Ownable {
    using Strings for uint256;
    using SafeERC20 for IERC20;

    // Storage
    address public contractAddress1;
    address public contractAddress2;

    // Admin contracts
    address public circuitBreakerAddress;
    address public comptrollerAddress;
    address public timelockAddress;
    address public hyperlendPairRegistryAddress;
    address public hyperlendWhitelistAddress;

    // Default swappers
    address[] public defaultSwappers;

    /// @notice Amount of asset to seed into each pair on creation
    uint256 amountToSeed;

    /// @notice Emits when a new pair is deployed
    /// @notice The ```LogDeploy``` event is emitted when a new Pair is deployed
    /// @param address_ The address of the pair
    /// @param asset The address of the Asset Token contract
    /// @param collateral The address of the Collateral Token contract
    /// @param name The name of the Pair
    /// @param configData The config data of the Pair
    /// @param immutables The immutables of the Pair
    /// @param customConfigData The custom config data of the Pair
    event LogDeploy(
        address indexed address_,
        address indexed asset,
        address indexed collateral,
        string name,
        bytes configData,
        bytes immutables,
        bytes customConfigData
    );

    /// @notice List of the names of all deployed Pairs
    address[] public deployedPairsArray;

    constructor(ConstructorParams memory _params) Ownable() {
        circuitBreakerAddress = _params.circuitBreaker;
        comptrollerAddress = _params.comptroller;
        timelockAddress = _params.timelock;
        hyperlendWhitelistAddress = _params.hyperlendWhitelist;
        hyperlendPairRegistryAddress = _params.hyperlendPairRegistry;
    }

    function version() external pure returns (uint256 _major, uint256 _minor, uint256 _patch) {
        return (5, 0, 0);
    }

    // ============================================================================================
    // Functions: View Functions
    // ============================================================================================

    /// @notice The ```deployedPairsLength``` function returns the length of the deployedPairsArray
    /// @return length of array
    function deployedPairsLength() external view returns (uint256) {
        return deployedPairsArray.length;
    }

    /// @notice The ```getAllPairAddresses``` function returns all pair addresses in deployedPairsArray
    /// @return _deployedPairs memory All deployed pair addresses
    function getAllPairAddresses() external view returns (address[] memory _deployedPairs) {
        _deployedPairs = deployedPairsArray;
    }

    function getNextNameSymbol(
        address _asset,
        address _collateral
    ) public view returns (string memory _name, string memory _symbol) {
        _name = string(
            abi.encodePacked(
                'Hyperlend Interest Bearing ',
                IERC20(_asset).safeSymbol(),
                ' (',
                IERC20(_collateral).safeName(),
                ')'
            )
        );
        _symbol = string(
            abi.encodePacked(
                'h',
                IERC20(_asset).safeSymbol(),
                '(',
                IERC20(_collateral).safeSymbol(),
                ')'
            )
        );
    }

    // ============================================================================================
    // Functions: Setters
    // ============================================================================================

    /// @notice The ```setCreationCode``` function sets the bytecode for the hyperlendPair
    /// @dev splits the data if necessary to accommodate creation code that is slightly larger than 24kb
    /// @dev creation code must always be larger than 13kb, otherwise it will revert
    /// @param _creationCode The creationCode for the Hyperlend Pair
    function setCreationCode(bytes calldata _creationCode) external onlyOwner {
        bytes memory _firstHalf = BytesLib.slice(_creationCode, 0, 13_000);
        contractAddress1 = SSTORE2.write(_firstHalf);
        if (_creationCode.length > 13_000) {
            bytes memory _secondHalf = BytesLib.slice(
                _creationCode,
                13_000,
                _creationCode.length - 13_000
            );
            contractAddress2 = SSTORE2.write(_secondHalf);
        }else {
            contractAddress2 = address(0);
        }
    }

    /// @notice The ```setDefaultSwappers``` function is used to set default list of approved swappers
    /// @param _swappers The list of swappers to set as default allowed
    function setDefaultSwappers(address[] memory _swappers) external onlyOwner {
        defaultSwappers = _swappers;
    }

    /// @notice The ```SetTimelock``` event is emitted when the timelockAddress is set
    /// @param oldAddress The original address
    /// @param newAddress The new address
    event SetTimelock(address oldAddress, address newAddress);

    /// @notice The ```setTimelock``` function sets the timelockAddress
    /// @param _newAddress the new time lock address
    function setTimelock(address _newAddress) external onlyOwner {
        emit SetTimelock(timelockAddress, _newAddress);
        timelockAddress = _newAddress;
    }

    /// @notice The ```SetRegistry``` event is emitted when the hyperlendPairRegistryAddress is set
    /// @param oldAddress The old address
    /// @param newAddress The new address
    event SetRegistry(address oldAddress, address newAddress);

    /// @notice The ```setRegistry``` function sets the hyperlendPairRegistryAddress
    /// @param _newAddress The new address
    function setRegistry(address _newAddress) external onlyOwner {
        emit SetRegistry(hyperlendPairRegistryAddress, _newAddress);
        hyperlendPairRegistryAddress = _newAddress;
    }

    /// @notice The ```SetComptroller``` event is emitted when the comptrollerAddress is set
    /// @param oldAddress The old address
    /// @param newAddress The new address
    event SetComptroller(address oldAddress, address newAddress);

    /// @notice The ```setComptroller``` function sets the comptrollerAddress
    /// @param _newAddress The new address
    function setComptroller(address _newAddress) external onlyOwner {
        emit SetComptroller(comptrollerAddress, _newAddress);
        comptrollerAddress = _newAddress;
    }

    /// @notice The ```SetWhitelist``` event is emitted when the hyperlendWhitelistAddress is set
    /// @param oldAddress The old address
    /// @param newAddress The new address
    event SetWhitelist(address oldAddress, address newAddress);

    /// @notice The ```setWhitelist``` function sets the hyperlendWhitelistAddress
    /// @param _newAddress The new address
    function setWhitelist(address _newAddress) external onlyOwner {
        emit SetWhitelist(hyperlendWhitelistAddress, _newAddress);
        hyperlendWhitelistAddress = _newAddress;
    }

    /// @notice The ```SetCircuitBreaker``` event is emitted when the circuitBreakerAddress is set
    /// @param oldAddress The old address
    /// @param newAddress The new address
    event SetCircuitBreaker(address oldAddress, address newAddress);

    /// @notice The ```setCircuitBreaker``` function sets the circuitBreakerAddress
    /// @param _newAddress The new address
    function setCircuitBreaker(address _newAddress) external onlyOwner {
        emit SetCircuitBreaker(circuitBreakerAddress, _newAddress);
        circuitBreakerAddress = _newAddress;
    }

        /// @notice the ```SetAmountToSeed``` event is emitted when the AmountToSeed is set
    /// @param oldAmountToSeed The old amount to seed new pairs
    /// @param newAmountToSeed The new amount to seed new pairs
    event SetAmountToSeed(uint256 oldAmountToSeed, uint256 newAmountToSeed);

    /// @notice the ```setAmountToSeed``` function sets the amount of asset to seed a pair
    ///         on creation
    /// @param _amountToSeed The amount of assets to seed the newly created pairs
    function setAmountToSeed(uint256 _amountToSeed) external {
        if (!IHyperlendWhitelist(hyperlendWhitelistAddress).hyperlendDeployerWhitelist(msg.sender)) {
            revert WhitelistedDeployersOnly();
        }
        emit SetAmountToSeed(amountToSeed, _amountToSeed);
        amountToSeed = _amountToSeed;
    }

    // ============================================================================================
    // Functions: Internal Methods
    // ============================================================================================

    /// @notice The ```_deploy``` function is an internal function with deploys the pair
    /// @param _configData abi.encode(address _asset, address _collateral, address _oracle, uint32 _maxOracleDeviation, address _rateContract, uint64 _fullUtilizationRate, uint256 _maxLTV, uint256 _cleanLiquidationFee, uint256 _dirtyLiquidationFee, uint256 _protocolLiquidationFee)
    /// @param _immutables abi.encode(address _circuitBreakerAddress, address _comptrollerAddress, address _timelockAddress)
    /// @param _customConfigData abi.encode(string memory _nameOfContract, string memory _symbolOfContract, uint8 _decimalsOfContract)
    /// @return _pairAddress The address to which the Pair was deployed
    function _deploy(
        bytes memory _configData,
        bytes memory _immutables,
        bytes memory _customConfigData
    ) private returns (address _pairAddress) {
        // Get creation code
        bytes memory _creationCode = SSTORE2.read(contractAddress1);
        if (contractAddress2 != address(0)) {
            _creationCode = BytesLib.concat(_creationCode, SSTORE2.read(contractAddress2));
        }

        // Get bytecode
        bytes memory bytecode = abi.encodePacked(
            _creationCode,
            abi.encode(_configData, _immutables, _customConfigData)
        );

        // Generate salt using constructor params
        bytes32 salt = keccak256(abi.encodePacked(_configData, _immutables, _customConfigData));

        /// @solidity memory-safe-assembly
        assembly {
            _pairAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        if (_pairAddress == address(0)) revert Create2Failed();

        deployedPairsArray.push(_pairAddress);

        // Set additional values for HyperlendPair
        IHyperlendPair _hyperlendPair = IHyperlendPair(_pairAddress);
        address[] memory _defaultSwappers = defaultSwappers;
        for (uint256 i = 0; i < _defaultSwappers.length; i++) {
            _hyperlendPair.setSwapper(_defaultSwappers[i], true);
        }

        return _pairAddress;
    }

    // ============================================================================================
    // Functions: External Deploy Methods
    // ============================================================================================

    /// @notice The ```deploy``` function allows the deployment of a HyperlendPair with default values
    /// @param _configData abi.encode(address _asset, address _collateral, address _oracle, uint32 _maxOracleDeviation, address _rateContract, uint64 _fullUtilizationRate, uint256 _maxLTV, uint256 _cleanLiquidationFee, uint256 _protocolLiquidationFee)
    /// @return _pairAddress The address to which the Pair was deployed
    function deploy(bytes memory _configData) external returns (address _pairAddress) {
        if (
            !IHyperlendWhitelist(hyperlendWhitelistAddress).hyperlendDeployerWhitelist(msg.sender)
        ) {
            revert WhitelistedDeployersOnly();
        }

        (address _asset, address _collateral, , , , , , , ) = abi.decode(
            _configData,
            (address, address, address, uint32, address, uint64, uint256, uint256, uint256)
        );

        (string memory _name, string memory _symbol) = getNextNameSymbol(_asset, _collateral);

        bytes memory _immutables = abi.encode(
            circuitBreakerAddress,
            comptrollerAddress,
            timelockAddress
        );
        bytes memory _customConfigData = abi.encode(_name, _symbol, IERC20(_asset).safeDecimals());

        _pairAddress = _deploy(_configData, _immutables, _customConfigData);

        IHyperlendPairRegistry(hyperlendPairRegistryAddress).addPair(_pairAddress);


        if (amountToSeed == 0) revert MustSeedPair();
        IERC20(_asset).safeApprove(_pairAddress, amountToSeed);
        IHyperlendPair(_pairAddress).deposit(amountToSeed, address(this));

        emit LogDeploy(
            _pairAddress,
            _asset,
            _collateral,
            _name,
            _configData,
            _immutables,
            _customConfigData
        );
    }

    // ============================================================================================
    // Functions: Admin
    // ============================================================================================

    /// @notice The ```globalPause``` function calls the pause() function on a given set of pair addresses
    /// @dev Ignores reverts when calling pause()
    /// @param _addresses Addresses to attempt to pause()
    /// @return _updatedAddresses Addresses for which pause() was successful
    function globalPause(
        address[] memory _addresses
    ) external returns (address[] memory _updatedAddresses) {
        if (msg.sender != circuitBreakerAddress) revert CircuitBreakerOnly();

        address _pairAddress;
        uint256 _lengthOfArray = _addresses.length;
        _updatedAddresses = new address[](_lengthOfArray);
        for (uint256 i = 0; i < _lengthOfArray; ) {
            _pairAddress = _addresses[i];
            try IHyperlendPair(_pairAddress).pause() {
                _updatedAddresses[i] = _addresses[i];
            } catch {}
            unchecked {
                i = i + 1;
            }
        }
    }

    // ============================================================================================
    // Errors
    // ============================================================================================

    error CircuitBreakerOnly();
    error WhitelistedDeployersOnly();
    error Create2Failed();
    error MustSeedPair();
}
