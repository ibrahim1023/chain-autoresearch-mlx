// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../contracts/gas_pack/manual/TokenLedgerManualComparator.sol";
import "../../contracts/gas_pack/manual/RewardDistributorManualComparator.sol";
import "../../contracts/gas_pack/manual/MerkleClaimerManualComparator.sol";

contract GasPackManualComparatorBenchmarkTest {
    address[] internal tokenAccounts32;
    uint256[] internal tokenAmounts32;

    address[] internal rewardAccounts16;
    uint256[] internal rewardShares16;

    address[] internal merkleAccounts8;
    uint256[] internal merkleEntitlements8;
    bytes32[] internal merkleLeaves8;
    bytes32 internal merkleRoot8;
    bytes32[] internal targetProof;

    function setUp() public {
        tokenAccounts32 = new address[](32);
        tokenAmounts32 = new uint256[](32);
        for (uint256 i = 0; i < 32; ++i) {
            tokenAccounts32[i] = address(uint160(0x4000 + i));
            tokenAmounts32[i] = (i + 1) * 3;
        }

        rewardAccounts16 = new address[](16);
        rewardShares16 = new uint256[](16);
        for (uint256 i = 0; i < 16; ++i) {
            rewardAccounts16[i] = address(uint160(0x5000 + i));
            rewardShares16[i] = i + 1;
        }

        merkleAccounts8 = new address[](8);
        merkleEntitlements8 = new uint256[](8);
        merkleLeaves8 = new bytes32[](8);
        for (uint256 i = 0; i < 8; ++i) {
            merkleAccounts8[i] = address(uint160(0x6000 + i));
            merkleEntitlements8[i] = (i + 1) * 25;
            merkleLeaves8[i] = keccak256(abi.encode(merkleAccounts8[i], merkleEntitlements8[i]));
        }

        merkleRoot8 = _buildMerkleRoot(merkleLeaves8);
        targetProof = _buildProof(merkleLeaves8, 5);
    }

    function testGasTokenLedgerMintBatch32() public {
        TokenLedgerManualComparator ledger = new TokenLedgerManualComparator();
        ledger.mintBatch(tokenAccounts32, tokenAmounts32);
    }

    function testGasTokenLedgerTransferFanout8() public {
        TokenLedgerManualComparator ledger = new TokenLedgerManualComparator();

        address[] memory minters = new address[](1);
        uint256[] memory mintAmounts = new uint256[](1);
        minters[0] = address(this);
        mintAmounts[0] = 1_000;
        ledger.mintBatch(minters, mintAmounts);

        for (uint256 i = 0; i < 8; ++i) {
            ledger.transfer(tokenAccounts32[i], 10 + i);
        }
    }

    function testGasRewardDistributorSetShares16() public {
        RewardDistributorManualComparator distributor = new RewardDistributorManualComparator();
        distributor.setShares(rewardAccounts16, rewardShares16);
    }

    function testGasRewardDistributorClaimAfterDeposit16() public {
        RewardDistributorManualComparator distributor = new RewardDistributorManualComparator();
        distributor.setShares(rewardAccounts16, rewardShares16);
        distributor.depositRewards(13_600);
        distributor.claim(rewardAccounts16[5]);
    }

    function testGasMerkleClaimerClaimDepth3() public {
        MerkleClaimerManualComparator claimer = new MerkleClaimerManualComparator(merkleRoot8);
        claimer.claim(merkleAccounts8[5], merkleEntitlements8[5], targetProof);
    }

    function _buildMerkleRoot(bytes32[] memory leaves) internal pure returns (bytes32) {
        while (leaves.length > 1) {
            uint256 nextLength = leaves.length / 2;
            bytes32[] memory nextLevel = new bytes32[](nextLength);

            for (uint256 i = 0; i < nextLength; ++i) {
                nextLevel[i] = _hashPair(leaves[i * 2], leaves[i * 2 + 1]);
            }

            leaves = nextLevel;
        }

        return leaves[0];
    }

    function _buildProof(bytes32[] memory leaves, uint256 index) internal pure returns (bytes32[] memory proof) {
        proof = new bytes32[](3);
        uint256 proofIndex = 0;

        while (leaves.length > 1) {
            uint256 siblingIndex = index ^ 1;
            proof[proofIndex] = leaves[siblingIndex];
            ++proofIndex;

            uint256 nextLength = leaves.length / 2;
            bytes32[] memory nextLevel = new bytes32[](nextLength);

            for (uint256 i = 0; i < nextLength; ++i) {
                nextLevel[i] = _hashPair(leaves[i * 2], leaves[i * 2 + 1]);
            }

            leaves = nextLevel;
            index /= 2;
        }
    }

    function _hashPair(bytes32 a, bytes32 b) internal pure returns (bytes32) {
        return a <= b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }
}
