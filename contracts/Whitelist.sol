pragma solidity ^0.4.19;

import "eip820/contracts/EIP820Implementer.sol";
import "giveth-common-contracts/contracts/Owned.sol";
import "./TokenValidator.sol";

// Reference Validator

contract Whitelist is TokenValidator, Owned, EIP820Implementer {
  mapping(address => bool) private onlyOwner whitelist;

  function Whitelist() public { }

  function check(address _token, address _user) public /* view */ returns (uint8 resultCode) {
    return whitelist[_user] ? 1 : 0;
  }

  function check(
      address _token,
      address _from,
      address _to,
      uint256 _amount
  ) public /* view */ returns (uint8 resultCode) {
    return (whitelist[_from] && whitelist[_to]) ? 1 : 0;
  }

  function updateWhitelist(address _user, bool _status) public onlyOwner {
      whitelist[_user] = _status;
  }
}
