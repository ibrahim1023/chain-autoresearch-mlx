// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../contracts/gas_pack/TokenLedger.sol";
import "../../contracts/gas_pack/RewardDistributor.sol";
import "../../contracts/gas_pack/MerkleClaimer.sol";
import "../../contracts/gas_pack/VaultAccounting.sol";

contract GasPackBenchmarkTest {
    address[] internal tokenAccounts32;
    uint256[] internal tokenAmounts32;

    address[] internal rewardAccounts16;
    uint256[] internal rewardShares16;

    address[] internal merkleAccounts8;
    uint256[] internal merkleEntitlements8;
    bytes32[] internal merkleLeaves8;
    bytes32 internal merkleRoot8;
    bytes32[] internal targetProof;

    address[] internal vaultAccounts8;

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

        vaultAccounts8 = new address[](8);
        for (uint256 i = 0; i < 8; ++i) {
            vaultAccounts8[i] = address(uint160(0x7000 + i));
        }
    }

    function testGasTokenLedgerMintBatch32() public {
        TokenLedger ledger = new TokenLedger();
        ledger.mintBatch(tokenAccounts32, tokenAmounts32);
    }

    function testGasTokenLedgerTransferFanout8() public {
        TokenLedger ledger = new TokenLedger();

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
        RewardDistributor distributor = new RewardDistributor();
        distributor.setShares(rewardAccounts16, rewardShares16);
    }

    function testGasRewardDistributorClaimAfterDeposit16() public {
        RewardDistributor distributor = new RewardDistributor();
        distributor.setShares(rewardAccounts16, rewardShares16);
        distributor.depositRewards(13_600);
        distributor.claim(rewardAccounts16[5]);
    }

    function testGasMerkleClaimerClaimDepth3() public {
        MerkleClaimer claimer = new MerkleClaimer(merkleRoot8);
        claimer.claim(merkleAccounts8[5], merkleEntitlements8[5], targetProof);
    }

    function testGasVaultAccountingDepositBootstrap() public {
        VaultAccounting vault = new VaultAccounting();
        uint256 sharesMinted = vault.deposit(vaultAccounts8[0], 1_000);

        require(sharesMinted == 1_000, "wrong bootstrap shares");
        require(vault.totalShares() == 1_000, "wrong total shares");
        require(vault.totalAssets() == 1_000, "wrong total assets");
    }

    function testGasVaultAccountingDepositAfterDonation() public {
        VaultAccounting vault = new VaultAccounting();
        vault.deposit(vaultAccounts8[0], 1_000);
        vault.donate(500);

        uint256 sharesMinted = vault.deposit(vaultAccounts8[1], 750);

        require(sharesMinted == 500, "wrong donated-rate shares");
        require(vault.shareBalance(vaultAccounts8[0]) == 1_000, "wrong first share balance");
        require(vault.shareBalance(vaultAccounts8[1]) == 500, "wrong second share balance");
        require(vault.totalShares() == 1_500, "wrong total shares");
        require(vault.totalAssets() == 2_250, "wrong total assets");
    }

    function testGasVaultAccountingWithdrawExactAssets() public {
        VaultAccounting vault = new VaultAccounting();
        vault.deposit(vaultAccounts8[0], 1_000);
        vault.deposit(vaultAccounts8[1], 500);
        vault.donate(300);

        uint256 sharesBurned = vault.withdraw(vaultAccounts8[0], 240);

        require(sharesBurned == 200, "wrong burned shares");
        require(vault.shareBalance(vaultAccounts8[0]) == 800, "wrong first share balance");
        require(vault.totalShares() == 1_300, "wrong total shares");
        require(vault.totalAssets() == 1_560, "wrong total assets");
    }

    function testGasVaultAccountingRedeemFullPosition() public {
        VaultAccounting vault = new VaultAccounting();
        vault.deposit(vaultAccounts8[0], 1_000);
        vault.deposit(vaultAccounts8[1], 500);
        vault.donate(300);

        uint256 assetsOut = vault.redeem(vaultAccounts8[1], vault.shareBalance(vaultAccounts8[1]));

        require(assetsOut == 600, "wrong redeemed assets");
        require(vault.shareBalance(vaultAccounts8[1]) == 0, "wrong remaining shares");
        require(vault.totalShares() == 1_000, "wrong total shares");
        require(vault.totalAssets() == 1_200, "wrong total assets");
    }

    function testInvariantVaultAccountingDonationDoesNotChangeShares() public {
        VaultAccounting vault = new VaultAccounting();
        vault.deposit(vaultAccounts8[0], 80);
        vault.deposit(vaultAccounts8[1], 20);

        uint256 beforeA = vault.shareBalance(vaultAccounts8[0]);
        uint256 beforeB = vault.shareBalance(vaultAccounts8[1]);
        uint256 beforeTotalShares = vault.totalShares();

        vault.donate(25);

        require(vault.shareBalance(vaultAccounts8[0]) == beforeA, "first share changed");
        require(vault.shareBalance(vaultAccounts8[1]) == beforeB, "second share changed");
        require(vault.totalShares() == beforeTotalShares, "total shares changed");
        require(vault.totalAssets() == 125, "wrong total assets");
    }

    function testInvariantVaultAccountingFailedWithdrawalDoesNotMutateState() public {
        VaultAccounting vault = new VaultAccounting();
        vault.deposit(vaultAccounts8[0], 10);
        vault.donate(5);

        uint256 beforeShares = vault.shareBalance(vaultAccounts8[0]);
        uint256 beforeTotalShares = vault.totalShares();
        uint256 beforeTotalAssets = vault.totalAssets();

        (bool ok,) = address(vault).call(
            abi.encodeWithSelector(vault.withdraw.selector, vaultAccounts8[0], 16)
        );

        require(!ok, "expected oversized withdrawal to fail");
        require(vault.shareBalance(vaultAccounts8[0]) == beforeShares, "share balance changed");
        require(vault.totalShares() == beforeTotalShares, "total shares changed");
        require(vault.totalAssets() == beforeTotalAssets, "total assets changed");
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
