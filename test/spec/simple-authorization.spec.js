// Because truffle does not support overloading
const SimpleAuthorization = artifacts.require('ExtendedSimpleAuthorization');

contract('SimpleAuthorization', (accounts) => {
  let simpleAuthorization;

  beforeEach(async () => {
    simpleAuthorization = await SimpleAuthorization.new()
  });

  it('should get instance of validator', () => {
    assert.isNotNull(simpleAuthorization);
    assert.isNotNull(simpleAuthorization.address);
  });


  it('ownder should be able to authorize and check auth', async () => {
      targetAccount = accounts[1];
      authorizedBefore = await simpleAuthorization.check2.call(0x0, targetAccount);
      assert(authorizedBefore == 0, 'should not be already authorized');
      await simpleAuthorization.setAuthorized(targetAccount, true);
      authorizedAfter = await simpleAuthorization.check2.call(0x0, targetAccount);
      assert(authorizedAfter == 1, 'should become authorized');
      await simpleAuthorization.setAuthorized(targetAccount, false);
      authorizedAfter = await simpleAuthorization.check2.call(0x0, targetAccount);
      assert(authorizedAfter == 0, 'should become unauthorized');
  });

  it('transfer should pass validation only when both accounts are authorized', async () => {
      sender = accounts[1];
      receiver = accounts[2];
      authorizedBefore = await simpleAuthorization.check4.call(0x0, sender, receiver, 0);
      assert(authorizedBefore == 0, 'should not be already authorized');
      await simpleAuthorization.setAuthorized(receiver, true);
      authorizedAfter = await simpleAuthorization.check4.call(0x0, sender, receiver, 0);
      assert(authorizedAfter == 0, 'should still be unauthorized');
      await simpleAuthorization.setAuthorized(sender, true);
      authorizedAfter = await simpleAuthorization.check4.call(0x0, sender, receiver, 0);
      assert(authorizedAfter == 1, 'should become authorized');
  });
});
