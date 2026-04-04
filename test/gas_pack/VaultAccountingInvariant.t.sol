// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../contracts/gas_pack/VaultAccounting.sol";

contract VaultAccountingInvariantTest {
    VaultAccounting internal vault;
    address[] internal accounts;

    function setUp() public {
        vault = new VaultAccounting();

        accounts = new address[](3);
        accounts[0] = address(0x7101);
        accounts[1] = address(0x7102);
        accounts[2] = address(0x7103);
    }

    function testInvariantTrackedSharesMatchTotalSharesAcrossMixedFlows() public {
        vault.deposit(accounts[0], 100);
        vault.deposit(accounts[1], 50);
        _assertTrackedShares(150);

        vault.donate(50);
        _assertTrackedShares(150);

        vault.withdraw(accounts[0], 30);
        _assertTrackedShares(_sumTrackedShares());

        vault.deposit(accounts[2], 48);
        _assertTrackedShares(_sumTrackedShares());
    }

    function testInvariantDonationDoesNotChangeTrackedShareBalances() public {
        vault.deposit(accounts[0], 80);
        vault.deposit(accounts[1], 20);

        uint256 beforeA = vault.shareBalance(accounts[0]);
        uint256 beforeB = vault.shareBalance(accounts[1]);
        uint256 beforeTotalShares = vault.totalShares();

        vault.donate(25);

        require(vault.shareBalance(accounts[0]) == beforeA, "donation changed first shares");
        require(vault.shareBalance(accounts[1]) == beforeB, "donation changed second shares");
        require(vault.totalShares() == beforeTotalShares, "donation changed total shares");
        require(vault.totalAssets() == 125, "wrong donated total assets");
    }

    function testInvariantFailedWithdrawalDoesNotMutateState() public {
        vault.deposit(accounts[0], 10);
        vault.donate(5);

        uint256 beforeShares = vault.shareBalance(accounts[0]);
        uint256 beforeTotalShares = vault.totalShares();
        uint256 beforeTotalAssets = vault.totalAssets();

        (bool ok,) = address(vault).call(
            abi.encodeWithSelector(vault.withdraw.selector, accounts[0], 20)
        );

        require(!ok, "expected oversized withdrawal to fail");
        require(vault.shareBalance(accounts[0]) == beforeShares, "share balance changed");
        require(vault.totalShares() == beforeTotalShares, "total shares changed");
        require(vault.totalAssets() == beforeTotalAssets, "total assets changed");
    }

    function testInvariantPreviewHelpersRemainConsistentAfterStateChanges() public {
        vault.deposit(accounts[0], 100);
        vault.donate(50);

        require(vault.previewDeposit(75) == 50, "preview deposit mismatch");
        require(vault.previewWithdraw(30) == 20, "preview withdraw mismatch");
        require(vault.previewRedeem(40) == 60, "preview redeem mismatch");
    }

    function _assertTrackedShares(uint256 expectedTotal) internal view {
        uint256 trackedShares = _sumTrackedShares();

        require(trackedShares == expectedTotal, "tracked shares mismatch");
        require(vault.totalShares() == expectedTotal, "totalShares mismatch");
    }

    function _sumTrackedShares() internal view returns (uint256 trackedShares) {
        for (uint256 i = 0; i < accounts.length; ++i) {
            trackedShares += vault.shareBalance(accounts[i]);
        }
    }
}
