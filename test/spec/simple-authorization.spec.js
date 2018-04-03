const { assert } = require('chai');

// Because truffle does not support overloading
const SimpleAuthorization = artifacts.require('ExtendedSimpleAuthorization'); // eslint-disable-line no-undef

contract('SimpleAuthorization', (accounts) => { // eslint-disable-line no-undef
  let simpleAuthorization;

  beforeEach(async () => {
    simpleAuthorization = await SimpleAuthorization.new();
  });

  it('should get instance of validator', () => {
    assert.isNotNull(simpleAuthorization);
    assert.isNotNull(simpleAuthorization.address);
  });


  it('ownder should be able to authorize and check auth', async () => {
    const targetAccount = accounts[1];
    const authorizedBefore = await simpleAuthorization.check2.call(0x0, targetAccount);

    assert.equal(authorizedBefore, 0, 'should not be already authorized');

    await simpleAuthorization.setAuthorized(targetAccount, true);
    let authorizedAfter = await simpleAuthorization.check2.call(0x0, targetAccount);
    assert.equal(authorizedAfter, 1, 'should become authorized');

    await simpleAuthorization.setAuthorized(targetAccount, false);
    authorizedAfter = await simpleAuthorization.check2.call(0x0, targetAccount);
    assert.equal(authorizedAfter, 0, 'should become unauthorized');
  });

  it('transfer should pass validation only when both accounts are authorized', async () => {
    const [, sender, receiver] = accounts;

    const authorizedBefore = await simpleAuthorization.check4.call(0x0, sender, receiver, 0);
    assert.equal(authorizedBefore, 0, 'should not be already authorized');
    console.log(JSON.stringify(authorizedBefore));

    await simpleAuthorization.setAuthorized(receiver, true);
    let authorizedAfter = await simpleAuthorization.check4.call(0x0, sender, receiver, 0);
    assert.equal(authorizedAfter, 0, 'should still be unauthorized');

    await simpleAuthorization.setAuthorized(sender, true);
    authorizedAfter = await simpleAuthorization.check4.call(0x0, sender, receiver, 0);
    assert.equal(authorizedAfter, 1, 'should become authorized');
  });
});
