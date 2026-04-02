// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MerkleClaimer {
    error InvalidProof();
    error NothingToClaim();

    bytes32 public merkleRoot;
    mapping(address => uint256) public claimedAmount;

    constructor(bytes32 root) {
        merkleRoot = root;
    }

    function claim(address account, uint256 totalEntitlement, bytes32[] calldata proof)
        external
        returns (uint256 newlyClaimed)
    {
        bytes32 leaf = keccak256(abi.encode(account, totalEntitlement));
        if (!_verifyProof(leaf, proof)) revert InvalidProof();

        uint256 alreadyClaimed = claimedAmount[account];
        if (totalEntitlement <= alreadyClaimed) revert NothingToClaim();

        unchecked {
            newlyClaimed = totalEntitlement - alreadyClaimed;
        }
        claimedAmount[account] = totalEntitlement;
    }

    function _verifyProof(bytes32 leaf, bytes32[] calldata proof) internal view returns (bool) {
        bytes32 computed = leaf;
        uint256 length = proof.length;

        for (uint256 i = 0; i < length;) {
            bytes32 sibling = proof[i];
            if (computed <= sibling) {
                computed = keccak256(abi.encodePacked(computed, sibling));
            } else {
                computed = keccak256(abi.encodePacked(sibling, computed));
            }

            unchecked {
                ++i;
            }
        }

        return computed == merkleRoot;
    }
}
