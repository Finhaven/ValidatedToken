const SimpleAuthorization = artifacts.require('SimpleAuthorization');
const ReferenceToken = artifacts.require('ReferenceToken');

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
      await referenceToken.mint(targetAccount, amountToMint * granularity, '');

      balance = await referenceToken.balanceOf(targetAccount);
      assert.equal(balance, amountToMint * granularity);
  });

  it('reference token receiver (mint) should be authorized', async () => {
      targetAccount = accounts[1];
      const amountToMint = 100;

      try {
        await referenceToken.mint(targetAccount, amountToMint * granularity, '');
        throw "Should have failed";
      } catch (e) {
        assert(e.message == "VM Exception while processing transaction: revert", "incorrect error was thrown");
      }
      await simpleAuthorization.setAuthorized(targetAccount, true);
      await referenceToken.mint(targetAccount, amountToMint * granularity, '');
  });

  it('reference token receiver (transfer) should be authorized', async () => {
      sender = accounts[1];
      receiver = accounts[2];
      const amount = 100;
      await simpleAuthorization.setAuthorized(sender, true);
      await referenceToken.mint(sender, amount * granularity, '');
      try {
        await referenceToken.transfer(receiver, amount * granularity, {from: sender});
        throw "Should have failed";
      } catch (e) {
        assert(e.message == "VM Exception while processing transaction: revert", "incorrect error was thrown");
      }
      receiverBalance = await referenceToken.balanceOf(receiver);
      assert.equal(receiverBalance, 0);
  });

  it('tranfer tokens', async () => {
      sender = accounts[1];
      receiver = accounts[2];
      const amount = 100;
      await simpleAuthorization.setAuthorized(sender, true);
      await simpleAuthorization.setAuthorized(receiver, true);
      await referenceToken.mint(sender, amount * granularity, '');
      await referenceToken.transfer(receiver, amount * granularity, {from: sender});

      receiverBalance = await referenceToken.balanceOf(receiver);
      assert.equal(receiverBalance, amount * granularity);
  });



});
