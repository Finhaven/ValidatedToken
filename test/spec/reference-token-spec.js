const SimpleAuthorization = artifacts.require('SimpleAuthorization');
const ReferenceToken = artifacts.require('ReferenceToken');

async function failTransaction(func, args, errorMessage) {
  try {
    await func.apply(this, args);
    throw "Should have failed";
  } catch (e) {
    assert.equal(e.message, errorMessage);
  }
}

revertMessage = "VM Exception while processing transaction: revert";

contract('ReferenceToken', (accounts) => {
  let simpleAuthorization;
  let referenceToken;
  const name = "testToken";
  const symbol = "TKN";
  const granularity = 16;


  beforeEach(async () => {
    simpleAuthorization = await SimpleAuthorization.new()
    referenceToken = await ReferenceToken.new(name, symbol, granularity, simpleAuthorization.address);
  });

  it('should get instance of reference token', () => {
    assert.isNotNull(referenceToken);
  });

  it('authorized should get tokens', async () => {
      targetAccount = accounts[1];
      const amountToMint = 100;

      await simpleAuthorization.setAuthorized(targetAccount, true);
      mintResult = await referenceToken.mint(targetAccount, amountToMint * granularity);
      validationEvent = mintResult.logs[0];
      assert.equal(validationEvent.event, 'Validation');
      assert.equal(validationEvent.args.user, targetAccount);

      balance = await referenceToken.balanceOf(targetAccount);
      assert.equal(balance, amountToMint * granularity);
  });

  it('reference token receiver (mint) should be authorized', async () => {
      targetAccount = accounts[1];
      const amountToMint = 100;
      await failTransaction(referenceToken.mint, [targetAccount, amountToMint * granularity], revertMessage);
      await simpleAuthorization.setAuthorized(targetAccount, true);
      await referenceToken.mint(targetAccount, amountToMint * granularity);
  });

  it('reference token receiver (transfer) should be authorized', async () => {
      sender = accounts[1];
      receiver = accounts[2];
      const amount = 100;
      await simpleAuthorization.setAuthorized(sender, true);
      await referenceToken.mint(sender, amount * granularity);
      await failTransaction(referenceToken.transfer, [receiver, amount * granularity, {from: sender}], revertMessage);
      receiverBalance = await referenceToken.balanceOf(receiver);
      assert.equal(receiverBalance, 0);
  });

  it('tranfer tokens', async () => {
      sender = accounts[1];
      receiver = accounts[2];
      const amount = 100;
      authorized = await simpleAuthorization.check.call(referenceToken.address, sender, receiver, amount);
      assert.equal(authorized, false);

      await simpleAuthorization.setAuthorized(sender, true);
      await simpleAuthorization.setAuthorized(receiver, true);
      await referenceToken.mint(sender, amount * granularity);
      transferResult = await referenceToken.transfer(receiver, amount * granularity, {from: sender});

      validationEvent = transferResult.logs[0];
      assert.equal(validationEvent.event, 'Validation');
      assert.equal(validationEvent.args.from, sender);
      assert.equal(validationEvent.args.to, receiver);
      assert.equal(validationEvent.args.value, amount * granularity);

      receiverBalance = await referenceToken.balanceOf(receiver);
      assert.equal(receiverBalance, amount * granularity);
  });

});
