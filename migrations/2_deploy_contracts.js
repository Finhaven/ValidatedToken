const SimpleAuthorization = artifacts.require('SimpleAuthorization'); // eslint-disable-line no-undef
const ReferenceToken = artifacts.require('ReferenceToken'); // eslint-disable-line no-undef

const name = 'testToken';
const symbol = 'TTK';
const granularity = 16;

module.exports = function (deployer) {
  deployer.then(async () => {
    await deployer.deploy(SimpleAuthorization);
    await deployer.deploy(ReferenceToken, name, symbol, granularity, SimpleAuthorization.address);
  });
};
