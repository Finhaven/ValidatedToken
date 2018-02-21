pragma solidity ^0.4.19;

import "eip820/contracts/EIP820Implementer.sol";
import "giveth-common-contracts/contracts/Owned.sol";
import "./TokenValidator.sol";

// Reference Validator

contract SimpleAuthorization is TokenValidator, Owned, EIP820Implementer {
  mapping(address => bool) private authorizations;

  function Whitelist() public {
      setInterfaceImplementation("TokenValidator", this);
  }

  function check(address _token, address _user) public /* view */ returns (uint8 resultCode) {
      return authorizations[_user] ? 1 : 0;
  }

  function check(
      address _token,
      address _from,
      address _to,
      uint256 _amount
  ) public /* view */ returns (uint8 resultCode) {
      return (authorizations[_from] && authorizations[_to]) ? 1 : 0;
  }

  function setAuthorized(address _user, bool _status) public onlyOwner {
      authorizations[_user] = _status;
  }
}
