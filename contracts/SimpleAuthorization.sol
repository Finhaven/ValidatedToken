pragma solidity ^0.4.21;

import "./../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./TokenValidator.sol";

// Reference Validator

contract SimpleAuthorization is TokenValidator, Ownable {
    mapping(address => bool) private auths;

    function SimpleAuthorization() public Ownable {}

    function check(
        address /* token */,
        address _address
    ) external returns (byte resultCode) {
        if (auths[_address]) {
            return hex"11";
        } else {
            return hex"10";
        }
    }

    function check(
        address /* _token */,
        address _from,
        address _to,
        uint256 /* _amount */
    ) external returns (byte resultCode) {
        if (auths[_from] && auths[_to]) {
            return hex"11";
        } else {
            return hex"10";
        }
    }

    function setAuthorized(address _address, bool _status) public onlyOwner {
        auths[_address] = _status;
    }
}
