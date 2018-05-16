const { assert } = require('chai');

const Lunar = artifacts.require('Lunar'); // eslint-disable-line no-undef
const SimpleAuthorization = artifacts.require('SimpleAuthorization'); // eslint-disable-line no-undef

contract('Lunar', (accounts) => { // eslint-disable-line no-undef
  let validator;
  let lunar;

  const [, sender, receiver] = accounts;
  const [, targetAccount] = accounts;

  before(async () => {
    validator = await SimpleAuthorization.new();
    lunar = await Lunar.new(validator.address);
  });

  it('has the expected name', () => {
    assert(lunar.name, "Lunar Token - SAMPLE NO VALUE");
  });

  it('has 18 decimal places', () => {
    assert(lunar.decimals, 18);
  });
});
