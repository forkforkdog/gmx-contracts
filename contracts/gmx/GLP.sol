// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;
//NOTE: pragma was changed by fuzzer

import "../tokens/MintableBaseToken.sol";

contract GLP is MintableBaseToken {
    constructor() public MintableBaseToken("GMX LP", "GLP", 0) {}

    function id() external pure returns (string memory _name) {
        return "GLP";
    }
}
