pragma solidity ^0.4.19;

import "./dependencies/ERC820Implementer.sol";
import "./dependencies/Owned.sol";
import "./TokenValidator.sol";

// Reference Validator

contract SimpleAuthorization is TokenValidator, Owned, ERC820Implementer {
  mapping(address => bool) private authorizations;

  function SimpleAuthorization() public {
      // Not sure why it is here, but it does not work with ganache
      // setInterfaceImplementation("TokenValidator", this);
  }

  function check(address /* token */, address _address) public /* view */ returns (uint8 resultCode) {
      return authorizations[_address] ? 1 : 0;
  }

  function check(
      address /* _token */,
      address _from,
      address _to,
      uint256 /* _amount */
  ) public /* view */ returns (uint8 resultCode) {
      return (authorizations[_from] && authorizations[_to]) ? 1 : 0;
  }

  function setAuthorized(address _address, bool _status) public onlyOwner {
      authorizations[_address] = _status;
  }
}
