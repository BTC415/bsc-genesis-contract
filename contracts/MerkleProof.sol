pragma solidity 0.6.4;

import "./lib/Memory.sol";

library MerkleProof {
  function validateMerkleProof(bytes32 appHash, string memory storeName, bytes memory key, bytes memory value, bytes memory proof)
  internal view returns (bool) {
    if (appHash == bytes32(0)) {
      return false;
    }

    // | storeName | key length | key | value length | value | appHash  | proof |
    // | 32 bytes  | 32 bytes   |   | 32 bytes   |     | 32 bytes |
    bytes memory input = new bytes(128+key.length+value.length+proof.length);

    uint256 ptr = Memory.dataPtr(input);

    bytes memory storeNameBytes = bytes(storeName);
    /* solium-disable-next-line */
    assembly {
      mstore(ptr, mload(add(storeNameBytes, 32)))
    }

    uint256 src;
    uint256 length;

    // write key length and key to input
    ptr += 32;
    (src, length) = Memory.fromBytes(key);
    /* solium-disable-next-line */
    assembly {
      mstore(ptr, length)
    }
    ptr += 32;
    Memory.copy(src, ptr, length);

    // write value length and value to input
    ptr += length;
    (src, length) = Memory.fromBytes(value);
    /* solium-disable-next-line */
    assembly {
      mstore(ptr, length)
    }
    ptr += 32;
    Memory.copy(src, ptr, length);

    // write appHash to input
    ptr += length;
    /* solium-disable-next-line */
    assembly {
      mstore(ptr, appHash)
    }

    // write proof to input
    ptr += 32;
    (src,length) = Memory.fromBytes(proof);
    Memory.copy(src, ptr, length);

    length = input.length+32;

    uint256[1] memory result;
    /* solium-disable-next-line */
    assembly {
    // call validateMerkleProof precompile contract
    // Contract address: 0x65
      if iszero(staticcall(not(0), 0x65, input, length, result, 0x20)) {}
    }

    return result[0] == 0x01;
  }

  /**
   * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
   * defined by `root`. For this, a `proof` must be provided, containing
   * sibling hashes on the branch from the leaf to the root of the tree. Each
   * pair of leaves and each pair of pre-images are assumed to be sorted.
   */
  function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
    bytes32 computedHash = leaf;

    for (uint256 i = 0; i < proof.length; i++) {
        bytes32 proofElement = proof[i];

        if (computedHash <= proofElement) {
            // Hash(current computed hash + current element of the proof)
            computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
        } else {
            // Hash(current element of the proof + current computed hash)
            computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
        }
    }

    // Check if the computed hash (root) is equal to the provided root
    return computedHash == root;
  }
}
