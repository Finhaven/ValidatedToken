pragma solidity ^0.4.21;

import "./ValidatedToken.sol";
import "./TokenValidator.sol";

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract ReferenceToken is Ownable, ERC20, ValidatedToken {
    using SafeMath for uint256;

    string private mName;
    string private mSymbol;

    uint256 private mGranularity;
    uint256 private mTotalSupply;

    mapping(address => uint) private mBalances;
    mapping(address => mapping(address => bool)) private mAuthorized;
    mapping(address => mapping(address => uint256)) private mAllowed;

    uint8 public decimals = 18;

    // Single validator
    TokenValidator internal validator;

    function ReferenceToken(
        string         _name,
        string         _symbol,
        uint256        _granularity,
        TokenValidator _validator
    ) public {
        require(_granularity >= 1);

        mName = _name;
        mSymbol = _symbol;
        mTotalSupply = 0;
        mGranularity = _granularity;
        validator = TokenValidator(_validator);
    }

    // Validation Helpers

    function validate(address _user) internal returns (byte) {
        byte checkResult = validator.check(this, _user);
        emit Validation(checkResult, _user);
        return checkResult;
    }

    function validate(
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (byte) {
        byte checkResult = validator.check(this, _from, _to, _amount);
        emit Validation(checkResult, _from, _to, _amount);
        return checkResult;
    }

    // Status Code Helpers

    function isOk(byte _statusCode) internal pure returns (bool) {
        return (_statusCode & hex"0F") == 1;
    }

    function requireOk(byte _statusCode) internal pure {
        require(isOk(_statusCode));
    }

    function name() public constant returns (string) {
        return mName;
    }

    function symbol() public constant returns(string) {
        return mSymbol;
    }

    function granularity() public constant returns(uint256) {
        return mGranularity;
    }

    function totalSupply() public constant returns(uint256) {
        return mTotalSupply;
    }

    function balanceOf(address _tokenHolder) public constant returns (uint256) {
        return mBalances[_tokenHolder];
    }

    function isMultiple(uint256 _amount) internal view returns (bool) {
      return _amount.div(mGranularity).mul(mGranularity) == _amount;
    }

    function approve(address _spender, uint256 _amount) public returns (bool success) {
        if(validate(msg.sender, _spender, _amount) != 1) { return false; }

        mAllowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return mAllowed[_owner][_spender];
    }

    function mint(address _tokenHolder, uint256 _amount) public onlyOwner {
        requireOk(validate(_tokenHolder));
        require(isMultiple(_amount));

        mTotalSupply = mTotalSupply.add(_amount);
        mBalances[_tokenHolder] = mBalances[_tokenHolder].add(_amount);

        emit Transfer(0x0, _tokenHolder, _amount);
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {
        doSend(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        require(_amount <= mAllowed[_from][msg.sender]);

        mAllowed[_from][msg.sender] = mAllowed[_from][msg.sender].sub(_amount);
        doSend(_from, _to, _amount);
        return true;
    }

    function doSend(
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        require(canTransfer(_from, _to, _amount));

        mBalances[_from] = mBalances[_from].sub(_amount);
        mBalances[_to] = mBalances[_to].add(_amount);

        emit Transfer(_from, _to, _amount);
    }

    function canTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (bool) {
        return (
            (_to != address(0)) // Forbid sending to 0x0 (=burning)
            && isMultiple(_amount)
            && (mBalances[_from] >= _amount) // Ensure enough funds
            && isOk(validate(_from, _to, _amount)) // Ensure passes validation
        );
    }
}
