pragma solidity ^0.4.23;

import "../ReferenceToken.sol"

contract Lunar is ReferenceToken {
  constructor(address _validator)
    ReferenceToken("Lunar Token - SAMPLE NO VALUE", "LNRX", 1, _validator)
    public {
        mint(msg.sender, 5000000);
    }
}
