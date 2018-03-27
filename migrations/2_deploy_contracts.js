var SimpleAuthorization = artifacts.require("SimpleAuthorization");
var ReferenceToken = artifacts.require("ReferenceToken");

name = 'testToken';
symbol = 'TTK';
granularity = 16;

module.exports = function(deployer) {
  deployer.then(async () => {
      // await deployer.deploy(SimpleAuthorization);
      // await deployer.deploy(ReferenceToken, name, symbol, granularity, SimpleAuthorization.address);
  });
};
