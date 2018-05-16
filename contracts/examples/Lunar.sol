pragma solidity ^0.4.23;

import "../ReferenceToken.sol";
import "../TokenValidator.sol";

contract Lunar is ReferenceToken {
    constructor(TokenValidator _validator)
      ReferenceToken("Lunar Token - SAMPLE NO VALUE", "LNRX", 1, _validator)
      public {
          uint256 supply = 5000000;

          mTotalSupply = supply;
          mBalances[msg.sender] = supply;

          emit Transfer(0x0, msg.sender, supply);
      }
}
