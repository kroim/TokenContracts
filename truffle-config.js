require('dotenv').config();
const HDWalletProvider = require('truffle-hdwallet-provider');
const privateKey = process.env.privateKey;
const infuraKey = process.env.infuraKey
module.exports = {
  api_keys: {
    etherscan: process.env.etherKey,
    bscscan: process.env.BSCSCANAPIKEY
  },
  networks: {
    ropsten: {
      provider: function () {
        let privateKeys = [privateKey];
        return new HDWalletProvider(privateKeys, "https://ropsten.infura.io/v3/" + infuraKey)
      },
      network_id: 3, // eslint-disable-line camelcase
      gas: 5500000, // Ropsten has a lower block limit than mainnet
      confirmations: 2, // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200, // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true, // Skip dry run before migrations? (default: false for public nets )
    },
    rinkeby: {
      provider: function () {
        let privateKeys = [privateKey];
        return new HDWalletProvider(privateKeys, "https://rinkeby.infura.io/v3/" + infuraKey)
      },
      network_id: 4, // eslint-disable-line camelcase
      gas: 5500000, // Ropsten has a lower block limit than mainnet
      confirmations: 2, // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200, // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true, // Skip dry run before migrations? (default: false for public nets )
    },
    bsctestnet: {  // binance smart chain testnet
      provider: function() {
        // Or, pass an array of private keys, and optionally use a certain subset of addresses
        var privateKeys = [
          privateKey //
        ];
        
        return new HDWalletProvider(privateKeys, "https://data-seed-prebsc-1-s2.binance.org:8545");
      },
      network_id: 97, // eslint-disable-line camelcase
      gas: 29000000, // Ropsten has a lower block limit than mainnet
      // gasPrice: 25000000000, // 122 gwei
      confirmations: 2, // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200, // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true, // Skip dry run before migrations? (default: false for public nets )
    },
    bscmainnet: {  // binance smart chain testnet
      provider: function() {
        // Or, pass an array of private keys, and optionally use a certain subset of addresses
        var privateKeys = [
          privateKey
        ];
        
        return new HDWalletProvider(privateKeys, "https://bsc-dataseed.binance.org");
      },
      network_id: 56, // eslint-disable-line camelcase
      gas: 29000000, // Ropsten has a lower block limit than mainnet
      // gasPrice: 25000000000, // 122 gwei
      confirmations: 2, // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200, // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true, // Skip dry run before migrations? (default: false for public nets )
    },
  },
  compilers: {
    solc: {
      version: "^0.8.0",
      settings: {
        optimizer: {
          enabled: true, // Default: false
          runs: 200     // Default: 200
        },
        evmVersion: "istanbul"
      }
    }
  },
  plugins: [
    'truffle-plugin-verify'
  ]
};
