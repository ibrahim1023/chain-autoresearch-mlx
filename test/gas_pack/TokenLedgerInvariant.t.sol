// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../contracts/gas_pack/TokenLedger.sol";

contract LedgerActor {
    TokenLedger internal immutable ledger;

    constructor(TokenLedger ledger_) {
        ledger = ledger_;
    }

    function transferOut(address to, uint256 amount) external returns (bool) {
        return ledger.transfer(to, amount);
    }

    function burnOwn(uint256 amount) external returns (bool) {
        return ledger.burn(amount);
    }
}

contract TokenLedgerInvariantTest {
    TokenLedger internal ledger;
    LedgerActor internal actorA;
    LedgerActor internal actorB;
    LedgerActor internal actorC;

    function setUp() public {
        ledger = new TokenLedger();
        actorA = new LedgerActor(ledger);
        actorB = new LedgerActor(ledger);
        actorC = new LedgerActor(ledger);
    }

    function testInvariantSupplyMatchesTrackedBalancesAcrossScenario() public {
        address[] memory accounts = new address[](3);
        uint256[] memory amounts = new uint256[](3);
        accounts[0] = address(actorA);
        accounts[1] = address(actorB);
        accounts[2] = address(actorC);
        amounts[0] = 50;
        amounts[1] = 30;
        amounts[2] = 20;

        ledger.mintBatch(accounts, amounts);
        _assertTrackedSupply(100);

        bool ok = actorA.transferOut(address(actorB), 10);
        require(ok, "actorA transfer failed");
        _assertTrackedSupply(100);

        ok = actorB.burnOwn(5);
        require(ok, "actorB burn failed");
        _assertTrackedSupply(95);

        ok = actorC.transferOut(address(actorA), 8);
        require(ok, "actorC transfer failed");
        _assertTrackedSupply(95);

        address[] memory moreAccounts = new address[](2);
        uint256[] memory moreAmounts = new uint256[](2);
        moreAccounts[0] = address(actorA);
        moreAccounts[1] = address(actorC);
        moreAmounts[0] = 7;
        moreAmounts[1] = 9;

        ledger.mintBatch(moreAccounts, moreAmounts);
        _assertTrackedSupply(111);
    }

    function testInvariantFailedOperationsDoNotChangeTrackedSupply() public {
        address[] memory accounts = new address[](2);
        uint256[] memory amounts = new uint256[](2);
        accounts[0] = address(actorA);
        accounts[1] = address(actorB);
        amounts[0] = 12;
        amounts[1] = 8;

        ledger.mintBatch(accounts, amounts);
        _assertTrackedSupply(20);

        (bool ok,) = address(actorA).call(
            abi.encodeWithSelector(actorA.transferOut.selector, address(actorB), 13)
        );
        require(!ok, "expected oversized transfer to fail");
        _assertTrackedSupply(20);

        (bool burnOk,) = address(actorB).call(
            abi.encodeWithSelector(actorB.burnOwn.selector, 9)
        );
        require(!burnOk, "expected oversized burn to fail");
        _assertTrackedSupply(20);
    }

    function _assertTrackedSupply(uint256 expectedSupply) internal view {
        uint256 trackedBalances =
            ledger.balanceOf(address(actorA)) + ledger.balanceOf(address(actorB)) + ledger.balanceOf(address(actorC));

        require(ledger.totalSupply() == expectedSupply, "unexpected total supply");
        require(trackedBalances == expectedSupply, "tracked balances diverged from supply");
    }
}
