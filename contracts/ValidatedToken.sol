pragma solidity ^0.4.19;

interface ValidatedToken {
  event Validation(
    uint8   indexed result,
    address indexed user
  );

  event Validation(
    uint8   indexed result,
    address indexed from,
    address indexed to,
    uint256         value
  );
}
