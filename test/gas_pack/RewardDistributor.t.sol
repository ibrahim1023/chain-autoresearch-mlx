// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../contracts/gas_pack/RewardDistributor.sol";

contract RewardDistributorTest {
    RewardDistributor internal distributor;
    address[] internal accounts;
    uint256[] internal shareValues;

    function setUp() public {
        distributor = new RewardDistributor();

        accounts = new address[](2);
        shareValues = new uint256[](2);

        accounts[0] = address(0x2001);
        accounts[1] = address(0x2002);

        shareValues[0] = 1;
        shareValues[1] = 3;
    }

    function testSetSharesTracksTotalShares() public {
        distributor.setShares(accounts, shareValues);

        require(distributor.totalShares() == 4, "wrong total shares");
        require(distributor.shares(accounts[0]) == 1, "wrong first share");
        require(distributor.shares(accounts[1]) == 3, "wrong second share");
    }

    function testSetSharesRevertsOnLengthMismatch() public {
        uint256[] memory shortShares = new uint256[](1);
        shortShares[0] = 1;

        (bool ok,) = address(distributor).call(
            abi.encodeWithSelector(distributor.setShares.selector, accounts, shortShares)
        );

        require(!ok, "expected length mismatch revert");
    }

    function testDepositRewardsUpdatesPendingRewards() public {
        distributor.setShares(accounts, shareValues);
        distributor.depositRewards(40);

        require(distributor.pendingReward(accounts[0]) == 10, "wrong first pending reward");
        require(distributor.pendingReward(accounts[1]) == 30, "wrong second pending reward");
    }

    function testDepositRewardsRevertsWithoutShares() public {
        (bool ok,) = address(distributor).call(
            abi.encodeWithSelector(distributor.depositRewards.selector, 1)
        );

        require(!ok, "expected no shares revert");
    }

    function testClaimMovesPendingIntoClaimedRewards() public {
        distributor.setShares(accounts, shareValues);
        distributor.depositRewards(40);

        uint256 claimed = distributor.claim(accounts[1]);

        require(claimed == 30, "wrong claimed amount");
        require(distributor.claimedRewards(accounts[1]) == 30, "wrong claimed storage");
        require(distributor.pendingReward(accounts[1]) == 0, "pending reward not cleared");
    }

    function testClaimRevertsWhenNothingIsPending() public {
        distributor.setShares(accounts, shareValues);

        (bool ok,) = address(distributor).call(
            abi.encodeWithSelector(distributor.claim.selector, accounts[0])
        );

        require(!ok, "expected nothing-to-claim revert");
    }
}
