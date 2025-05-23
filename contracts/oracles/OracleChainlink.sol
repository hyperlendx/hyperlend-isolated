// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';
import {IStaticOracle} from '@mean-finance/uniswap-v3-oracle/solidity/interfaces/IStaticOracle.sol';
import {IERC20Metadata} from '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import {Timelock2Step} from '../Timelock2Step.sol';

/// @title OracleChainlink
/// @notice An oracle using a single Chainlink price feed
contract OracleChainlink is Timelock2Step {
    uint128 public constant ORACLE_PRECISION = 1e18;
    address public immutable BASE_TOKEN;
    address public immutable QUOTE_TOKEN;

    // Chainlink Config
    address public immutable CHAINLINK_MULTIPLY_ADDRESS;
    address public immutable CHAINLINK_DIVIDE_ADDRESS;
    uint256 public immutable CHAINLINK_NORMALIZATION;
    uint256 public maxOracleDelay;

    // Config Data
    uint8 internal constant DECIMALS = 18;
    string public name;
    uint256 immutable public oracleType = 1;

    // events
    /// @notice The ```SetMaxOracleDelay``` event is emitted when the max oracle delay is set
    /// @param oldMaxOracleDelay The old max oracle delay
    /// @param newMaxOracleDelay The new max oracle delay
    event SetMaxOracleDelay(uint256 oldMaxOracleDelay, uint256 newMaxOracleDelay);

    constructor(
        address _baseToken,
        address _quoteToken,
        address _chainlinkMultiplyAddress,
        address _chainlinkDivideAddress,
        uint256 _maxOracleDelay,
        address _timelockAddress,
        string memory _name
    ) Timelock2Step() {
        _setTimelock({_newTimelock: _timelockAddress});

        BASE_TOKEN = _baseToken;
        QUOTE_TOKEN = _quoteToken;
        CHAINLINK_MULTIPLY_ADDRESS = _chainlinkMultiplyAddress;
        CHAINLINK_DIVIDE_ADDRESS = _chainlinkDivideAddress;
        uint8 _multiplyDecimals = _chainlinkMultiplyAddress != address(0)
            ? AggregatorV3Interface(_chainlinkMultiplyAddress).decimals()
            : 0;
        uint8 _divideDecimals = _chainlinkDivideAddress != address(0)
            ? AggregatorV3Interface(_chainlinkDivideAddress).decimals()
            : 0;
        require(_divideDecimals + IERC20Metadata(_quoteToken).decimals() <= _multiplyDecimals + IERC20Metadata(_baseToken).decimals() + 18, "negative exponent");
        CHAINLINK_NORMALIZATION =
            10 **
                (18 +
                    _multiplyDecimals -
                    _divideDecimals +
                    IERC20Metadata(_baseToken).decimals() -
                    IERC20Metadata(_quoteToken).decimals());

        maxOracleDelay = _maxOracleDelay;

        name = _name;
    }

    /// @notice The ```setMaxOracleDelay``` function sets the max oracle delay to determine if Chainlink data is stale
    /// @dev Requires msg.sender to be the timelock address
    /// @param _newMaxOracleDelay The new max oracle delay
    function setMaxOracleDelay(uint256 _newMaxOracleDelay) external {
        _requireTimelock();
        emit SetMaxOracleDelay(maxOracleDelay, _newMaxOracleDelay);
        maxOracleDelay = _newMaxOracleDelay;
    }

    function _getChainlinkPrice() internal view returns (bool _isBadData, uint256 _price) {
        _price = uint256(1e36);

        if (CHAINLINK_MULTIPLY_ADDRESS != address(0)) {
            (, int256 _answer, , uint256 _updatedAt, ) = AggregatorV3Interface(
                CHAINLINK_MULTIPLY_ADDRESS
            ).latestRoundData();

            // If data is stale or negative, set bad data to true and return
            if (_answer <= 0 || (block.timestamp - _updatedAt > maxOracleDelay)) {
                revert("invalid oracle price");
            }
            _price = _price * uint256(_answer);
        }

        if (CHAINLINK_DIVIDE_ADDRESS != address(0)) {
            (, int256 _answer, , uint256 _updatedAt, ) = AggregatorV3Interface(
                CHAINLINK_DIVIDE_ADDRESS
            ).latestRoundData();

            // If data is stale or negative, set bad data to true and return
            if (_answer <= 0 || (block.timestamp - _updatedAt > maxOracleDelay)) {
                revert("invalid oracle price");
            }
            _price = _price / uint256(_answer);
        }

        // return price as ratio of Collateral/Asset including decimal differences
        // CHAINLINK_NORMALIZATION = 10**(18 + asset.decimals() - collateral.decimals() + multiplyOracle.decimals() - divideOracle.decimals())
        _price = _price / CHAINLINK_NORMALIZATION;
    }

    /// @notice The ```getPrices``` function is intended to return two prices from different oracles
    /// @return _isBadData is true when chainlink data is stale or negative
    /// @return _priceLow is the lower of the two prices
    /// @return _priceHigh is the higher of the two prices
    function getPrices()
        external
        view
        returns (bool _isBadData, uint256 _priceLow, uint256 _priceHigh)
    {
        uint256 _price;
        (_isBadData, _price) = _getChainlinkPrice();

        _priceLow = _price;
        _priceHigh = _price;
    }

    function decimals() external pure returns (uint8) {
        return DECIMALS;
    }
}
