pragma solidity ^0.4.19;

interface TokenValidator {
  function check(
    address _token,
    address _user
  ) public returns(uint8 result);

  function check(
    address _token,
    address _from,
    address _to,
    uint256 _amount
  ) public returns (uint8 result);
}
