require('dotenv/config');

require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-etherscan')

module.exports = {
  networks: {
    // bscTestnet: {
    //   url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
    //   chainId: 97,
    //   gasPrice: 20000000000,
    //   accounts: [process.env.PRIVATE_KEY],
    // },
    goerli: {
      url: process.env.GOERLI_URL,
      chainId: 5,
      gasPrice: 20000000000,
      accounts: [process.env.PRIVATE_KEY],
    }
  },
  solidity: {
    version: "0.8.7",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: "./contracts/",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  mocha: {
    timeout: 20000,
  },
  etherscan: {
    apiKey: {
      goerli: process.env.API_KEY
    },
  },
};