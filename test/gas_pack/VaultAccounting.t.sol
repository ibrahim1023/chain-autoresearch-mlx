// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../contracts/gas_pack/VaultAccounting.sol";

contract VaultAccountingTest {
    VaultAccounting internal vault;

    address internal constant ALICE = address(0x7001);
    address internal constant BOB = address(0x7002);

    function setUp() public {
        vault = new VaultAccounting();
    }

    function testDepositBootstrapsOneToOneShares() public {
        uint256 sharesMinted = vault.deposit(ALICE, 100);

        require(sharesMinted == 100, "wrong bootstrap shares");
        require(vault.shareBalance(ALICE) == 100, "wrong alice shares");
        require(vault.totalShares() == 100, "wrong total shares");
        require(vault.totalAssets() == 100, "wrong total assets");
    }

    function testDepositAfterDonationUsesCurrentRate() public {
        vault.deposit(ALICE, 100);
        vault.donate(50);

        uint256 sharesMinted = vault.deposit(BOB, 75);

        require(sharesMinted == 50, "wrong donated-rate shares");
        require(vault.shareBalance(ALICE) == 100, "alice shares changed");
        require(vault.shareBalance(BOB) == 50, "wrong bob shares");
        require(vault.totalShares() == 150, "wrong total shares");
        require(vault.totalAssets() == 225, "wrong total assets");
    }

    function testWithdrawBurnsRoundedUpShares() public {
        vault.deposit(ALICE, 100);
        vault.donate(50);

        uint256 sharesBurned = vault.withdraw(ALICE, 31);

        require(sharesBurned == 21, "wrong burned shares");
        require(vault.shareBalance(ALICE) == 79, "wrong alice shares");
        require(vault.totalShares() == 79, "wrong total shares");
        require(vault.totalAssets() == 119, "wrong total assets");
    }

    function testRedeemReturnsProRataAssets() public {
        vault.deposit(ALICE, 100);
        vault.donate(50);

        uint256 assetsOut = vault.redeem(ALICE, 40);

        require(assetsOut == 60, "wrong redeemed assets");
        require(vault.shareBalance(ALICE) == 60, "wrong remaining shares");
        require(vault.totalShares() == 60, "wrong total shares");
        require(vault.totalAssets() == 90, "wrong total assets");
    }

    function testDonateChangesAssetsWithoutChangingShares() public {
        vault.deposit(ALICE, 25);
        vault.deposit(BOB, 25);

        vault.donate(10);

        require(vault.shareBalance(ALICE) == 25, "alice shares changed");
        require(vault.shareBalance(BOB) == 25, "bob shares changed");
        require(vault.totalShares() == 50, "total shares changed");
        require(vault.totalAssets() == 60, "wrong total assets");
    }

    function testDonateRevertsWithoutShares() public {
        (bool ok,) = address(vault).call(
            abi.encodeWithSelector(vault.donate.selector, 1)
        );

        require(!ok, "expected donate-without-shares revert");
    }

    function testPreviewHelpersMatchState() public {
        vault.deposit(ALICE, 100);
        vault.donate(50);

        require(vault.previewDeposit(75) == 50, "wrong preview deposit");
        require(vault.previewWithdraw(31) == 21, "wrong preview withdraw");
        require(vault.previewRedeem(40) == 60, "wrong preview redeem");
    }

    function testWithdrawRevertsOnInsufficientShares() public {
        vault.deposit(ALICE, 10);
        vault.donate(5);

        (bool ok,) = address(vault).call(
            abi.encodeWithSelector(vault.withdraw.selector, ALICE, 20)
        );

        require(!ok, "expected insufficient shares revert");
    }
}
