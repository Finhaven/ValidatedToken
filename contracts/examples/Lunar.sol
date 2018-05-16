pragma solidity ^0.4.23;

import "../ReferenceToken.sol";
import "../TokenValidator.sol";

contract Lunar is ReferenceToken {
    constructor(TokenValidator _validator)
      ReferenceToken("Lunar Token - SAMPLE NO VALUE", "LNRX", 1, _validator)
      public {
          mint(msg.sender, 5000000);
      }
}
