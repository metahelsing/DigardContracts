// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library AddressStringConverter {
    function addressToString(
        address _address
    ) internal pure returns (string memory) {
        bytes32 result;
        assembly {
            // Convert address to bytes32
            result := mload(0x40)
            mstore(result, _address)
        }
        return bytes32ToString(result);
    }

    function bytes32ToString(
        bytes32 _bytes32
    ) internal pure returns (string memory) {
        uint8 i = 0;
        while (i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (uint8 j = 0; j < i; j++) {
            bytesArray[j] = _bytes32[j];
        }
        return string(bytesArray);
    }
}
