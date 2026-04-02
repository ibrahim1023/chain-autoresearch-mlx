// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../contracts/gas_pack/RewardDistributor.sol";

contract RewardDistributorInvariantTest {
    RewardDistributor internal distributor;
    address[] internal accounts;

    function setUp() public {
        distributor = new RewardDistributor();

        accounts = new address[](3);
        accounts[0] = address(0x4101);
        accounts[1] = address(0x4102);
        accounts[2] = address(0x4103);
    }

    function testInvariantTotalSharesMatchesTrackedSharesAcrossUpdates() public {
        uint256[] memory initialShares = new uint256[](3);
        initialShares[0] = 2;
        initialShares[1] = 3;
        initialShares[2] = 5;
        distributor.setShares(accounts, initialShares);
        _assertTrackedShares(10);

        uint256[] memory updatedShares = new uint256[](3);
        updatedShares[0] = 4;
        updatedShares[1] = 1;
        updatedShares[2] = 6;
        distributor.setShares(accounts, updatedShares);
        _assertTrackedShares(11);

        uint256[] memory reducedShares = new uint256[](3);
        reducedShares[0] = 0;
        reducedShares[1] = 7;
        reducedShares[2] = 2;
        distributor.setShares(accounts, reducedShares);
        _assertTrackedShares(9);
    }

    function testInvariantClaimedPlusPendingNeverExceedsDistributedRewards() public {
        uint256[] memory shareValues = new uint256[](3);
        shareValues[0] = 2;
        shareValues[1] = 3;
        shareValues[2] = 5;
        distributor.setShares(accounts, shareValues);

        distributor.depositRewards(101);
        distributor.depositRewards(53);

        distributor.claim(accounts[0]);
        distributor.claim(accounts[2]);

        uint256 claimedAndPending = _sumClaimedRewards() + _sumPendingRewards();
        uint256 distributed = distributor.totalRewardsDistributed();
        uint256 remainder = distributed - claimedAndPending;

        require(claimedAndPending <= distributed, "tracked rewards exceed deposits");
        require(remainder < distributor.totalShares(), "rounding remainder too large");
    }

    function testInvariantClaimUpdatesOnlyClaimedAccountState() public {
        uint256[] memory shareValues = new uint256[](3);
        shareValues[0] = 1;
        shareValues[1] = 4;
        shareValues[2] = 5;
        distributor.setShares(accounts, shareValues);
        distributor.depositRewards(100);

        uint256 claimedBefore = distributor.claimedRewards(accounts[1]);
        uint256 pendingBeforeClaim = distributor.pendingReward(accounts[1]);
        uint256 untouchedPendingBefore = distributor.pendingReward(accounts[2]);

        uint256 payout = distributor.claim(accounts[1]);

        require(payout == pendingBeforeClaim, "claim payout mismatch");
        require(distributor.claimedRewards(accounts[1]) == claimedBefore + payout, "claimed storage mismatch");
        require(distributor.pendingReward(accounts[1]) == 0, "pending not cleared");
        require(distributor.pendingReward(accounts[2]) == untouchedPendingBefore, "claim touched another account");
    }

    function _assertTrackedShares(uint256 expectedTotal) internal view {
        uint256 trackedTotal;
        for (uint256 i = 0; i < accounts.length; ++i) {
            trackedTotal += distributor.shares(accounts[i]);
        }

        require(trackedTotal == expectedTotal, "unexpected tracked share total");
        require(distributor.totalShares() == expectedTotal, "unexpected totalShares");
    }

    function _sumClaimedRewards() internal view returns (uint256 totalClaimed) {
        for (uint256 i = 0; i < accounts.length; ++i) {
            totalClaimed += distributor.claimedRewards(accounts[i]);
        }
    }

    function _sumPendingRewards() internal view returns (uint256 totalPending) {
        for (uint256 i = 0; i < accounts.length; ++i) {
            totalPending += distributor.pendingReward(accounts[i]);
        }
    }
}
