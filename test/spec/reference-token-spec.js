const { assert } = require('chai');
const { failTransaction, revertMessage } = require('./helpers');

const SimpleAuthorization = artifacts.require('SimpleAuthorization'); // eslint-disable-line no-undef
const ReferenceToken = artifacts.require('ReferenceToken'); // eslint-disable-line no-undef

contract('ReferenceToken', (accounts) => { // eslint-disable-line no-undef
  const name = 'testToken';
  const symbol = 'TKN';
  const granularity = 16;
  const amount = 100;

  const [, sender, receiver] = accounts;
  const [, targetAccount] = accounts;

  let simpleAuthorization;
  let referenceToken;

  beforeEach(async () => {
    simpleAuthorization = await SimpleAuthorization.new();

    referenceToken =
      await ReferenceToken.new(name, symbol, granularity, simpleAuthorization.address);
  });

  it('should get instance of reference token', () => {
    assert.isNotNull(referenceToken);
  });

  it('authorized should get tokens', async () => {
    await simpleAuthorization.setAuthorized(targetAccount, true);
    const mintResult = await referenceToken.mint(targetAccount, amount * granularity);
    const validationEvent = mintResult.logs[0];

    assert.equal(validationEvent.event, 'Validation');
    assert.equal(validationEvent.args.user, targetAccount);

    const balance = await referenceToken.balanceOf(targetAccount);
    assert.equal(balance, amount * granularity);
  });

  it('reference token receiver (mint) should be authorized', async () => {
    await failTransaction(
      referenceToken.mint,
      [targetAccount, amount * granularity],
      revertMessage,
    );

    await simpleAuthorization.setAuthorized(targetAccount, true);
    await referenceToken.mint(targetAccount, amount * granularity);
  });

  it('reference token receiver (transfer) should be authorized', async () => {
    await simpleAuthorization.setAuthorized(sender, true);
    await referenceToken.mint(sender, amount * granularity);
    await failTransaction(
      referenceToken.transfer,
      [receiver, amount * granularity, { from: sender }],
      revertMessage,
    );

    const receiverBalance = await referenceToken.balanceOf(receiver);
    assert.equal(receiverBalance, 0);
  });

  it('tranfer tokens', async () => {
    const authorized =
      await simpleAuthorization.check.call(referenceToken.address, sender, receiver, amount);

    assert.equal(authorized, '0x10');

    await simpleAuthorization.setAuthorized(sender, true);
    await simpleAuthorization.setAuthorized(receiver, true);
    await referenceToken.mint(sender, amount * granularity);

    const transferResult =
      await referenceToken.transfer(receiver, amount * granularity, { from: sender });

    const validationEvent = transferResult.logs[0];
    assert.equal(validationEvent.event, 'Validation');
    assert.equal(validationEvent.args.from, sender);
    assert.equal(validationEvent.args.to, receiver);
    assert.equal(validationEvent.args.value, amount * granularity);

    const receiverBalance = await referenceToken.balanceOf(receiver);
    assert.equal(receiverBalance, amount * granularity);
  });
});
