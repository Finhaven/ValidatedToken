pragma solidity ^0.4.21;

interface TokenValidator {
  function check(
    address _token,
    address _user
  ) external returns(byte result);

  function check(
    address _token,
    address _from,
    address _to,
    uint256 _amount
  ) external returns (byte result);
}
