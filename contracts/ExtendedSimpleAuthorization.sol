pragma solidity ^0.4.21;

import "./SimpleAuthorization.sol";

// Truffle overloading workaround
contract ExtendedSimpleAuthorization is SimpleAuthorization {
    function check2(address _token, address _address) public returns (byte resultCode) {
        return this.check(_token,_address);
    }

    function check4(
        address _token,
        address _from,
        address _to,
        uint256 _amount
    ) public returns (byte resultCode) {
        return this.check(_token, _from, _to, _amount);
    }

}
