// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../contracts/gas_pack/manual/MerkleClaimerManualComparator.sol";

contract MerkleClaimerManualComparatorTest {
    address internal constant ALICE = address(0x3001);
    address internal constant BOB = address(0x3002);

    function testClaimAcceptsValidProof() public {
        bytes32 aliceLeaf = keccak256(abi.encode(ALICE, uint256(10)));
        bytes32 bobLeaf = keccak256(abi.encode(BOB, uint256(20)));
        bytes32 root = _hashPair(aliceLeaf, bobLeaf);

        MerkleClaimerManualComparator claimer = new MerkleClaimerManualComparator(root);

        bytes32[] memory proof = new bytes32[](1);
        proof[0] = bobLeaf;

        uint256 claimed = claimer.claim(ALICE, 10, proof);

        require(claimed == 10, "wrong claimed amount");
        require(claimer.claimedAmount(ALICE) == 10, "wrong stored claimed amount");
    }

    function testClaimRejectsInvalidProof() public {
        bytes32 aliceLeaf = keccak256(abi.encode(ALICE, uint256(10)));
        bytes32 bobLeaf = keccak256(abi.encode(BOB, uint256(20)));
        bytes32 root = _hashPair(aliceLeaf, bobLeaf);

        MerkleClaimerManualComparator claimer = new MerkleClaimerManualComparator(root);

        bytes32[] memory proof = new bytes32[](1);
        proof[0] = bytes32(uint256(123));

        (bool ok,) = address(claimer).call(
            abi.encodeWithSelector(claimer.claim.selector, ALICE, 10, proof)
        );

        require(!ok, "expected invalid proof revert");
    }

    function testClaimRevertsWhenNothingNewIsAvailable() public {
        bytes32 aliceLeaf10 = keccak256(abi.encode(ALICE, uint256(10)));
        bytes32 bobLeaf20 = keccak256(abi.encode(BOB, uint256(20)));
        bytes32 root10 = _hashPair(aliceLeaf10, bobLeaf20);

        MerkleClaimerManualComparator claimer = new MerkleClaimerManualComparator(root10);

        bytes32[] memory proof = new bytes32[](1);
        proof[0] = bobLeaf20;

        uint256 firstClaim = claimer.claim(ALICE, 10, proof);
        require(firstClaim == 10, "wrong first claim");

        (bool ok,) = address(claimer).call(
            abi.encodeWithSelector(claimer.claim.selector, ALICE, 10, proof)
        );

        require(!ok, "expected duplicate claim revert");
    }

    function _hashPair(bytes32 a, bytes32 b) internal pure returns (bytes32) {
        return a <= b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }
}
