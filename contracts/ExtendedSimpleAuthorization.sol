pragma solidity ^0.4.19;

import "./SimpleAuthorization.sol";

// Truffle overloading workaround
contract ExtendedSimpleAuthorization is SimpleAuthorization {

    function check2(address _token, address _address) public /* view */ returns (uint8 resultCode) {
        return check(_token,_address);
    }

    function check4(address _token, address _from, address _to, uint256 _amount) public /* view */ returns (uint8 resultCode) {
        return check(_token, _from, _to, _amount);
    }

}
