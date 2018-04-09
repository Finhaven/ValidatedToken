pragma solidity ^0.4.19;

interface TokenValidator {
  function check(
    address _token,
    address _user
  ) public returns(byte result);

  function check(
    address _token,
    address _from,
    address _to,
    uint256 _amount
  ) public returns (byte result);
}
