// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;
//NOTE: pragma was changed by fuzzer

import "../tokens/MintableBaseToken.sol";

contract EsGMX is MintableBaseToken {
    constructor() public MintableBaseToken("Escrowed GMX", "esGMX", 0) {}

    function id() external pure returns (string memory _name) {
        return "esGMX";
    }
}
