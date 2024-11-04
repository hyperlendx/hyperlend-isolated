// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';

contract MockChainlinkOracle is AggregatorV3Interface {
    uint256 public version = 1;
    uint8 public decimals = 8;
    string public description = "MOCK/USD";

    uint256 _answer = 100_000_000;

    constructor(uint256 newAnswer){
        _answer = newAnswer;
    }

    function setAnswer(uint256 newAnswer) external {
        _answer = newAnswer;
    }

    function getRoundData(uint80 _roundId) external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        roundId = _roundId;
        answer = int256(_answer);
        startedAt = block.timestamp;
        updatedAt = block.timestamp;
        answeredInRound = _roundId;
    }


    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        roundId = 1;
        answer = int256(_answer);
        startedAt = block.timestamp;
        updatedAt = block.timestamp;
        answeredInRound = 1;
    }
}
