pragma solidity ^0.4.19;

import "./ValidatedToken.sol";
import "./TokenValidator.sol";

import "eip777/contracts/ReferenceToken.sol";
import "giveth-common-contracts/contracts/SafeMath.sol";

contract DiffToken is ReferenceToken {
    string private mName;
    string private mSymbol;

    uint256 private mGranularity;
    uint256 private mTotalSupply;

    bool private mErc20compatible;

    mapping(address => uint) private mBalances;

    mapping(address => mapping(address => bool))    private mAuthorized;
    mapping(address => mapping(address => uint256)) private mAllowed;

    // Single validator
    TokenValidator private validator;

    function DiffToken(
        string         _name,
        string         _symbol,
        uint256        _granularity,
        TokenValidator _validator
    ) public ReferenceToken(_name, _symbol, _granularity) {
        validator = TokenValidator(_validator);
    }

    // Validation Helpers

    function validate(address _user) private returns (uint8 resultCode) {
        return validator.check(this, _user);
    }

    function validate(
        address _from,
        address _to,
        uint256 _amount
    ) private returns (uint8 resultCode) {
        return validator.check(this, _from, _to, _amount);
    }

    // Status Code Helpers

    function requireOk(uint8 _statusCode) internal pure {
      require(_statusCode == 1);
    }

    // Overrides

    function authorizeOperator(address _operator) public {
        requireOk(validate(_operator));
        super.authorizeOperator(_operator);
    }

    function mint(address _tokenHolder, uint256 _amount, bytes _operatorData) public onlyOwner {
        requireOk(validate(_tokenHolder));
        super.mint(_tokenHolder, _amount, _operatorData);
    }

    function transferFrom(address _from, address _to, uint256 _amount) public erc20 returns (bool success) {
        requireOk(validate(_from, _to, _amount));
        return super.transferFrom(_from, _to, _amount);
    }

    function approve(address _spender, uint256 _amount) public erc20 returns (bool success) {
        if(validate(msg.sender, _spender, _amount) != 1) {
          return false;
        } else {
          return super.approve(_spender, _amount);
        }
    }

    function doSend(
        address _from,
        address _to,
        uint256 _amount,
        bytes _userData,
        address _operator,
        bytes _operatorData,
        bool _preventLocking
    ) private {
        requireOk(validate(_from, _to, _amount));
        requireMultiple(_amount);
        require(_to != address(0));          // forbid sending to 0x0 (=burning)
        require(mBalances[_from] >= _amount); // ensure enough funds
        requireOk(validate(_from, _to, _amount)); // Ensure passes validation

        mBalances[_from] = mBalances[_from].sub(_amount);
        mBalances[_to] = mBalances[_to].add(_amount);

        callRecipient(_operator, _from, _to, _amount, _userData, _operatorData, _preventLocking);

        Sent(_from, _to, _amount, _userData, _operator, _operatorData);
        if (mErc20compatible) { Transfer(_from, _to, _amount); }
    }

    function callRecipient(
        address _operator,
        address _from,
        address _to,
        uint256 _amount,
        bytes _userData,
        bytes _operatorData,
        bool _preventLocking
    ) private {
        address recipientImplementation = interfaceAddr(_to, "ITokenRecipient");

        if (recipientImplementation != 0) {
          ITokenRecipient(recipientImplementation)
            .tokensReceived(_from, _to, _amount, _userData, _operator, _operatorData);
        } else if (_preventLocking) {
            require(isRegularAddress(_to));
        }
    }
}
