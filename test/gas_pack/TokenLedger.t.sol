// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../contracts/gas_pack/TokenLedger.sol";

contract TokenLedgerTest {
    TokenLedger internal ledger;
    address[] internal accounts;
    uint256[] internal amounts;

    function setUp() public {
        ledger = new TokenLedger();

        accounts = new address[](3);
        amounts = new uint256[](3);

        accounts[0] = address(0x1001);
        accounts[1] = address(0x1002);
        accounts[2] = address(0x1003);

        amounts[0] = 10;
        amounts[1] = 20;
        amounts[2] = 30;
    }

    function testMintBatchUpdatesBalancesAndSupply() public {
        uint256 minted = ledger.mintBatch(accounts, amounts);

        require(minted == 60, "wrong minted total");
        require(ledger.totalSupply() == 60, "wrong total supply");
        require(ledger.balanceOf(accounts[0]) == 10, "wrong first balance");
        require(ledger.balanceOf(accounts[2]) == 30, "wrong third balance");
    }

    function testMintBatchRevertsOnLengthMismatch() public {
        uint256[] memory shortAmounts = new uint256[](2);
        shortAmounts[0] = 1;
        shortAmounts[1] = 2;

        (bool ok,) = address(ledger).call(
            abi.encodeWithSelector(ledger.mintBatch.selector, accounts, shortAmounts)
        );

        require(!ok, "expected length mismatch revert");
    }

    function testMintBatchRevertsOnZeroAddress() public {
        address[] memory badAccounts = new address[](1);
        uint256[] memory oneAmount = new uint256[](1);
        badAccounts[0] = address(0);
        oneAmount[0] = 1;

        (bool ok,) = address(ledger).call(
            abi.encodeWithSelector(ledger.mintBatch.selector, badAccounts, oneAmount)
        );

        require(!ok, "expected zero address revert");
    }

    function testTransferMovesBalance() public {
        address[] memory senders = new address[](1);
        uint256[] memory senderAmounts = new uint256[](1);
        senders[0] = address(this);
        senderAmounts[0] = 60;

        ledger.mintBatch(senders, senderAmounts);

        (bool ok,) = address(ledger).call(
            abi.encodeWithSelector(ledger.transfer.selector, accounts[1], 4)
        );

        require(ok, "transfer failed");
        require(ledger.balanceOf(address(this)) == 56, "wrong sender balance");
        require(ledger.balanceOf(accounts[1]) == 4, "wrong recipient balance");
        require(ledger.totalSupply() == 60, "transfer changed supply");
    }

    function testTransferRevertsOnInsufficientBalance() public {
        (bool ok,) = address(ledger).call(
            abi.encodeWithSelector(ledger.transfer.selector, accounts[1], 1)
        );

        require(!ok, "expected insufficient balance revert");
    }

    function testBurnReducesBalanceAndSupply() public {
        address[] memory oneAccount = new address[](1);
        uint256[] memory oneAmount = new uint256[](1);
        oneAccount[0] = address(this);
        oneAmount[0] = 15;

        ledger.mintBatch(oneAccount, oneAmount);

        bool ok = ledger.burn(6);
        require(ok, "burn failed");
        require(ledger.balanceOf(address(this)) == 9, "wrong post-burn balance");
        require(ledger.totalSupply() == 9, "wrong post-burn supply");
    }

    function testBurnRevertsOnInsufficientBalance() public {
        (bool ok,) = address(ledger).call(
            abi.encodeWithSelector(ledger.burn.selector, 1)
        );

        require(!ok, "expected burn revert");
    }
}
