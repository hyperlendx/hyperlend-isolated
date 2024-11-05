### Modifications of the FraxLend codebase

- removed the `length` from the pair name & symbol: [commit](https://github.com/hyperlendx/hyperlend-isolated/commit/b1fd3ff0adb106a0d47cb271c84e8f7ea7d4931e). While this prevents deployment of 2 completely identical pairs, this is acceptable.
- added [ChainlinkOracle.sol](https://github.com/hyperlendx/hyperlend-isolated/blob/master/contracts/oracles/OracleChainLink.sol), used to read data only from chainlink price feeds (modified `DualOracleChainlinkUniV3`).

