// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;
//NOTE: pragma was changed by fuzzer

pragma experimental ABIEncoderV2;

abstract contract BasicMulticall {
    function multicall(
        bytes[] calldata data
    ) external virtual returns (bytes[] memory results) {
        results = new bytes[](data.length);

        for (uint256 i; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(
                data[i]
            );

            if (!success) {
                revert("call failed");
            }

            results[i] = result;
        }

        return results;
    }
}
