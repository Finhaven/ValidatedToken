const HDWalletProvider = require('truffle-hdwallet-provider');

const mnemonic = 'thunder scrap actual rate shallow snack health unit couch list amount age';
module.exports = {
  networks: {
    rinkeby: {
      provider() {
        return new HDWalletProvider(mnemonic, 'https://rinkeby.infura.io/0oGAYXzE57nJ4xYI6M0N');
      },
      network_id: '*',
    },
    development: {
      host: 'localhost',
      port: 8545,
      network_id: '*', // Match any network id
      // gas: Number(4712388 * 1.1).toFixed(0) // increase the default limit of 4712388
      gas: 6712388,
    },
  },
  mocha: {
    // reporter: 'eth-gas-reporter',
    growl: true,
  },

};
