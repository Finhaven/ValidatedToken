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

  it('creator should be able to authorize and check auth', async () => {
      targetAccount = accounts[1];
      authorizedBefore = await simpleAuthorization.check.call(0x0, targetAccount, targetAccount, 0);
      assert(authorizedBefore == 0, 'should not be already authorized');
      await simpleAuthorization.setAuthorized(targetAccount, true);
      authorizedAfter = await simpleAuthorization.check.call(0x0, targetAccount, targetAccount, 0);
      assert(authorizedAfter == 1, 'should become authorized');
      await simpleAuthorization.setAuthorized(targetAccount, false);
      authorizedAfter = await simpleAuthorization.check.call(0x0, targetAccount, targetAccount, 0);
      assert(authorizedAfter == 0, 'should become unauthorized');
  });

  it('transfer should pass validation only when both accounts are authorized', async () => {
      sender = accounts[1];
      receiver = accounts[2];
      authorizedBefore = await simpleAuthorization.check.call(0x0, sender, receiver, 0);
      assert(authorizedBefore == 0, 'should not be already authorized');
      await simpleAuthorization.setAuthorized(receiver, true);
      authorizedAfter = await simpleAuthorization.check.call(0x0, sender, receiver, 0);
      assert(authorizedAfter == 0, 'should still be unauthorized');
      await simpleAuthorization.setAuthorized(sender, true);
      authorizedAfter = await simpleAuthorization.check.call(0x0, sender, receiver, 0);
      assert(authorizedAfter == 1, 'should become authorized');
  });
});
