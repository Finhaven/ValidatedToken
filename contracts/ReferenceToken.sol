pragma solidity ^0.4.19;

import "./ValidatedToken.sol";
import "./TokenValidator.sol";

import "./dependencies/ERC820Implementer.sol";
import "./dependencies/Owned.sol";
import "./dependencies/SafeMath.sol";

import "./dependencies/ERC20Token.sol";
import "./dependencies/ERC777Token.sol";
import "./dependencies/ERC777TokensRecipient.sol";

// Adjusted from Ierc777/ReferenceToken.sol

contract ReferenceToken is Owned, ERC20Token, ERC777Token, ERC820Implementer {
    using SafeMath for uint256;

    string private mName;
    string private mSymbol;

    uint256 private mGranularity;
    uint256 private mTotalSupply;

    bool private mErc20compatible;

    mapping(address => uint) private mBalances;
    mapping(address => mapping(address => bool)) private mAuthorized;
    mapping(address => mapping(address => uint256)) private mAllowed;

    // Single validator
    TokenValidator private validator;

    function ReferenceToken(
        string         _name,
        string         _symbol,
        uint256        _granularity,
        TokenValidator _validator
    ) public {
        mName = _name;
        mSymbol = _symbol;
        mTotalSupply = 0;
        mErc20compatible = true;
        require(_granularity >= 1);
        mGranularity = _granularity;
        validator = TokenValidator(_validator);

        setInterfaceImplementation("Ierc777", this);
        setInterfaceImplementation("Ierc20", this);
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

    // EIP-777

    function name() public constant returns (string) { return mName; }

    function symbol() public constant returns(string) { return mSymbol; }

    function granularity() public constant returns(uint256) { return mGranularity; }

    function totalSupply() public constant returns(uint256) { return mTotalSupply; }

    function balanceOf(address _tokenHolder) public constant returns (uint256) { return mBalances[_tokenHolder]; }

    function send(address _to, uint256 _amount) public {
        doSend(msg.sender, _to, _amount, "", msg.sender, "", true);
    }

    function send(address _to, uint256 _amount, bytes _userData) public {
        doSend(msg.sender, _to, _amount, _userData, msg.sender, "", true);
    }

    function authorizeOperator(address _operator) public {
        require(_operator != msg.sender);
        requireOk(validate(_operator));

        mAuthorized[_operator][msg.sender] = true;
        AuthorizedOperator(_operator, msg.sender);
    }

    function revokeOperator(address _operator) public {
        require(_operator != msg.sender);
        mAuthorized[_operator][msg.sender] = false;
        RevokedOperator(_operator, msg.sender);
    }

    function isOperatorFor(address _operator, address _tokenHolder) public constant returns (bool) {
        return _operator == _tokenHolder || mAuthorized[_operator][_tokenHolder];
    }

    function operatorSend(address _from, address _to, uint256 _amount, bytes _userData, bytes _operatorData) public {
        require(isOperatorFor(msg.sender, _from));
        doSend(_from, _to, _amount, _userData, msg.sender, _operatorData, true);
    }

    function mint(address _tokenHolder, uint256 _amount, bytes _operatorData) public onlyOwner {
        requireOk(validate(_tokenHolder));
        requireMultiple(_amount);

        mTotalSupply = mTotalSupply.add(_amount);
        mBalances[_tokenHolder] = mBalances[_tokenHolder].add(_amount);

        callRecipient(msg.sender, 0x0, _tokenHolder, _amount, "", _operatorData, true);

        Minted(msg.sender, _tokenHolder, _amount, _operatorData);
        if (mErc20compatible) { Transfer(0x0, _tokenHolder, _amount); }
    }

    function burn(address _tokenHolder, uint256 _amount, bytes _userData, bytes _operatorData) public onlyOwner { // solhint-disable-line no-unused-vars
        requireMultiple(_amount);
        require(balanceOf(_tokenHolder) >= _amount);

        mBalances[_tokenHolder] = mBalances[_tokenHolder].sub(_amount);
        mTotalSupply = mTotalSupply.sub(_amount);

        Burned(msg.sender, _tokenHolder, _amount, _userData, _operatorData);
        if (mErc20compatible) { Transfer(_tokenHolder, 0x0, _amount); }
    }

    modifier erc20 () {
        require(mErc20compatible);
        _;
    }

    function disableERC20() public onlyOwner {
        mErc20compatible = false;
        setInterfaceImplementation("Ierc20", 0x0);
    }

    function enableERC20() public onlyOwner {
        mErc20compatible = true;
        setInterfaceImplementation("Ierc20", this);
    }

    function decimals() public erc20 constant returns (uint8) { return uint8(18); }

    function transfer(address _to, uint256 _amount) public erc20 returns (bool success) {
        doSend(msg.sender, _to, _amount, "", msg.sender, "", false);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public erc20 returns (bool success) {
        requireOk(validate(_from, _to, _amount));

        require(_amount <= mAllowed[_from][msg.sender]);

        // Cannot be after doSend because of tokensReceived re-entry
        mAllowed[_from][msg.sender] = mAllowed[_from][msg.sender].sub(_amount);
        doSend(_from, _to, _amount, "", msg.sender, "", false);
        return true;
    }

    function approve(address _spender, uint256 _amount) public erc20 returns (bool success) {
        if(validate(msg.sender, _spender, _amount) != 1) { return false; }

        mAllowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public erc20 constant returns (uint256 remaining) {
        return mAllowed[_owner][_spender];
    }

    function requireMultiple(uint256 _amount) internal view {
        require(_amount.div(mGranularity).mul(mGranularity) == _amount);
    }

    function isRegularAddress(address _addr) internal constant returns(bool) {
        if (_addr == 0) { return false; }
        uint size;
        assembly { size := extcodesize(_addr) } // solhint-disable-line no-inline-assembly
        return size == 0;
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

        Sent(_operator, _from, _to, _amount, _userData, _operatorData);
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
        address recipientImplementation = interfaceAddr(_to, "ERC777TokensRecipient");

        if (recipientImplementation != 0) {
          ERC777TokensRecipient(recipientImplementation)
            .tokensReceived(_operator, _from, _to, _amount, _userData, _operatorData);
        } else if (_preventLocking) {
            require(isRegularAddress(_to));
        }
    }
}
