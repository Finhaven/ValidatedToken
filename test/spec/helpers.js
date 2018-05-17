const { assert } = require('chai');

const revertMessage = 'VM Exception while processing transaction: revert';

async function failTransaction(func, args = [], errorMessage = revertMessage) {
  try {
    await func.apply(this, args);
    throw new Error('Should have failed');
  } catch (e) {
    assert.equal(e.message, errorMessage);
  }
}

module.exports = {
  revertMessage,
  failTransaction
};
