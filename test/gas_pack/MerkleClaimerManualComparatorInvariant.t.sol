// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../contracts/gas_pack/manual/MerkleClaimerManualComparator.sol";

contract MerkleClaimerManualComparatorInvariantTest {
    address internal constant ALICE = address(0x5101);
    address internal constant BOB = address(0x5102);
    address internal constant CAROL = address(0x5103);

    MerkleClaimerManualComparator internal claimer;
    bytes32 internal bobLeaf;
    bytes32 internal carolLeaf;
    bytes32[] internal aliceProof;
    bytes32[] internal bobProof;
    bytes32[] internal carolProof;

    function setUp() public {
        bytes32 aliceLeaf = keccak256(abi.encode(ALICE, uint256(10)));
        bobLeaf = keccak256(abi.encode(BOB, uint256(20)));
        carolLeaf = keccak256(abi.encode(CAROL, uint256(30)));

        bytes32 left = _hashPair(aliceLeaf, bobLeaf);
        bytes32 root = _hashPair(left, carolLeaf);
        claimer = new MerkleClaimerManualComparator(root);

        aliceProof = new bytes32[](2);
        aliceProof[0] = bobLeaf;
        aliceProof[1] = carolLeaf;

        bobProof = new bytes32[](2);
        bobProof[0] = aliceLeaf;
        bobProof[1] = carolLeaf;

        carolProof = new bytes32[](1);
        carolProof[0] = left;
    }

    function testInvariantClaimedAmountIsMonotonicPerAccount() public {
        uint256 firstClaim = claimer.claim(ALICE, 10, aliceProof);
        require(firstClaim == 10, "wrong first claim");
        require(claimer.claimedAmount(ALICE) == 10, "wrong first claimed amount");

        (bool ok,) = address(claimer).call(
            abi.encodeWithSelector(claimer.claim.selector, ALICE, 10, aliceProof)
        );
        require(!ok, "expected repeat claim to fail");
        require(claimer.claimedAmount(ALICE) == 10, "claimed amount changed after failed repeat");
    }

    function testInvariantInvalidProofDoesNotMutateClaimedState() public {
        bytes32[] memory invalidProof = new bytes32[](1);
        invalidProof[0] = bytes32(uint256(123));

        uint256 beforeAlice = claimer.claimedAmount(ALICE);
        uint256 beforeBob = claimer.claimedAmount(BOB);

        (bool ok,) = address(claimer).call(
            abi.encodeWithSelector(claimer.claim.selector, ALICE, 10, invalidProof)
        );

        require(!ok, "expected invalid proof to fail");
        require(claimer.claimedAmount(ALICE) == beforeAlice, "alice state changed on invalid proof");
        require(claimer.claimedAmount(BOB) == beforeBob, "bob state changed on invalid proof");
    }

    function testInvariantIndependentAccountsDoNotInterfere() public {
        uint256 aliceClaim = claimer.claim(ALICE, 10, aliceProof);
        uint256 bobClaim = claimer.claim(BOB, 20, bobProof);
        uint256 carolClaim = claimer.claim(CAROL, 30, carolProof);

        require(aliceClaim == 10, "wrong alice claim");
        require(bobClaim == 20, "wrong bob claim");
        require(carolClaim == 30, "wrong carol claim");

        require(claimer.claimedAmount(ALICE) == 10, "wrong alice claimed amount");
        require(claimer.claimedAmount(BOB) == 20, "wrong bob claimed amount");
        require(claimer.claimedAmount(CAROL) == 30, "wrong carol claimed amount");
    }

    function _hashPair(bytes32 a, bytes32 b) internal pure returns (bytes32) {
        return a <= b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }
}
