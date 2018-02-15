pragma solidity ^0.4.19;

import "eip820/contracts/EIP820Implementer.sol";
import "giveth-common-contracts/contracts/Owned.sol";
import "./TokenValidator.sol";

// Reference Validator

contract Whitelist is TokenValidator, Owned, EIP820Implementer {
  address[] private whitelist;

  function Whitelist(address[] _whitelist) public {
    whitelist = _whitelist;
    setInterfaceImplementation("TokenValidator", this);
  }

  function check(address _token, address _user) public /* view */ returns (uint8 resultCode) {
    uint8 result = 0;

    for(uint i = 0; i < whitelist.length; i++) {
      if (_user == whitelist[i]) {
        result = 1;
        break;
      }
    }

    return result;
  }

  function check(address _token, address _from, address _to, uint256 _amount) public /* view */ returns (uint8 resultCode) {
    bool  fromOk = false;
    bool  toOk   = false;
    uint8 result = 0;

    for(uint i = 0; i < whitelist.length; i++) {
      if (_from == whitelist[i]) { fromOk = true; }
      if (_to   == whitelist[i]) { toOk   = true; }

      if (toOk && fromOk) {
        result = 1;
        break;
      }
    }

    return result;
  }
}
