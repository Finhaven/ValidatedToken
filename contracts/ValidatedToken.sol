pragma solidity ^0.4.23;

interface ValidatedToken {
  event Validation(
    byte    indexed result,
    address indexed user
  );

  event Validation(
    byte    indexed result,
    address indexed from,
    address indexed to,
    uint256         value
  );
}
