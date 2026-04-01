// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract RewardDistributor {
    error LengthMismatch();
    error NoShares();
    error NothingToClaim();

    uint256 internal constant SCALE = 1e18;

    mapping(address => uint256) public shares;
    mapping(address => uint256) public rewardDebt;
    mapping(address => uint256) public claimedRewards;

    uint256 public totalShares;
    uint256 public accRewardPerShare;
    uint256 public totalRewardsDistributed;

    function setShares(address[] calldata accounts, uint256[] calldata newShares) external {
        uint256 length = accounts.length;
        if (length != newShares.length) revert LengthMismatch();

        for (uint256 i = 0; i < length; ++i) {
            address account = accounts[i];
            uint256 oldShare = shares[account];
            uint256 nextShare = newShares[i];

            if (nextShare > oldShare) {
                totalShares += nextShare - oldShare;
            } else if (oldShare > nextShare) {
                totalShares -= oldShare - nextShare;
            }

            shares[account] = nextShare;
            rewardDebt[account] = _accruedReward(nextShare);
        }
    }

    function depositRewards(uint256 amount) external returns (uint256 newAccRewardPerShare) {
        if (totalShares == 0) revert NoShares();

        accRewardPerShare += (amount * SCALE) / totalShares;
        totalRewardsDistributed += amount;
        return accRewardPerShare;
    }

    function pendingReward(address account) public view returns (uint256) {
        uint256 accrued = _accruedReward(shares[account]);
        uint256 debt = rewardDebt[account];
        if (accrued <= debt) {
            return 0;
        }
        return accrued - debt;
    }

    function claim(address account) external returns (uint256 payout) {
        payout = pendingReward(account);
        if (payout == 0) revert NothingToClaim();

        rewardDebt[account] += payout;
        claimedRewards[account] += payout;
    }

    function _accruedReward(uint256 shareAmount) internal view returns (uint256) {
        return (shareAmount * accRewardPerShare) / SCALE;
    }
}
