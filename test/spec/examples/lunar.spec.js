const { assert } = require('chai');

const Lunar = artifacts.require('Lunar'); // eslint-disable-line no-undef
const SimpleAuthorization = artifacts.require('SimpleAuthorization'); // eslint-disable-line no-undef

contract('Lunar', (accounts) => { // eslint-disable-line no-undef
  let validator;
  let lunar;

  const [, sender, receiver] = accounts;
  const [, targetAccount] = accounts;

  beforeEach(async () => {
    validator = await SimpleAuthorization.new();
    lunar = await Lunar.new(validator.address);
  });

  it('has the expected name', async () => {
    assert.equal(await lunar.name(), 'Lunar Token - SAMPLE NO VALUE');
  });

  it('has the symbol LNRX', async () => {
    assert.equal(await lunar.symbol(), 'LNRX');
  });

  it('has 18 decimal places', async () => {
    assert.equal(await lunar.decimals(), 18);
  });

  it('has a granularity of one', async () => {
    assert.equal(await lunar.granularity(), 1);
  });

  it('has a total supply of 5 million (six zeroes)', async () => {
    assert(await lunar.totalSupply(), 5000000);
  });
});
