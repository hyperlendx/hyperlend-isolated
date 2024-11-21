require("dotenv").config()
require("@nomicfoundation/hardhat-toolbox");

const mnemonic = process.env.MNEMONIC

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    networks: {
        hardhat: {
            gas: "auto",
            accounts: {
                mnemonic,
            },
            chainId: 1337,
        },
        hyperEvmTestnet: {
            accounts: {
                mnemonic,
            },
            chainId: 998,
            url: 'https://api.hyperliquid-testnet.xyz/evm',
        }
    },
    paths: {
        artifacts: "./artifacts",
        cache: "./cache",
        sources: "./contracts",
        tests: "./test",
    },
    solidity: {
        compilers: [
            {
                version: "0.8.19",
                settings: {
                    viaIR: true,
                    metadata: {
                        bytecodeHash: "none",
                    },
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
        ],
    },
};
