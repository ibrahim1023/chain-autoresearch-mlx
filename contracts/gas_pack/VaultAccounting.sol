// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VaultAccounting {
    error ZeroAddress();
    error ZeroAssets();
    error ZeroShares();
    error NoShares();
    error InsufficientShares();

    mapping(address => uint256) public shareBalance;
    uint256 public totalShares;
    uint256 public totalAssets;

    function deposit(address account, uint256 assets) external returns (uint256 sharesMinted) {
        if (account == address(0)) revert ZeroAddress();
        if (assets == 0) revert ZeroAssets();

        uint256 currentTotalShares = totalShares;
        uint256 currentTotalAssets = totalAssets;

        if (currentTotalShares == 0) {
            sharesMinted = assets;
        } else {
            sharesMinted = (assets * currentTotalShares) / currentTotalAssets;
            if (sharesMinted == 0) revert ZeroShares();
        }

        unchecked {
            shareBalance[account] += sharesMinted;
            totalShares = currentTotalShares + sharesMinted;
            totalAssets = currentTotalAssets + assets;
        }
    }

    function withdraw(address account, uint256 assets) external returns (uint256 sharesBurned) {
        if (account == address(0)) revert ZeroAddress();
        if (assets == 0) revert ZeroAssets();

        uint256 currentTotalShares = totalShares;
        uint256 currentTotalAssets = totalAssets;
        sharesBurned = _previewWithdraw(assets, currentTotalShares, currentTotalAssets);

        uint256 accountShares = shareBalance[account];
        if (accountShares < sharesBurned) revert InsufficientShares();

        unchecked {
            shareBalance[account] = accountShares - sharesBurned;
            totalShares = currentTotalShares - sharesBurned;
            totalAssets = currentTotalAssets - assets;
        }
    }

    function redeem(address account, uint256 shares) external returns (uint256 assetsOut) {
        if (account == address(0)) revert ZeroAddress();
        if (shares == 0) revert ZeroShares();

        uint256 accountShares = shareBalance[account];
        if (accountShares < shares) revert InsufficientShares();

        uint256 currentTotalShares = totalShares;
        uint256 currentTotalAssets = totalAssets;
        assetsOut = _previewRedeem(shares, currentTotalShares, currentTotalAssets);
        if (assetsOut == 0) revert ZeroAssets();

        unchecked {
            shareBalance[account] = accountShares - shares;
            totalShares = currentTotalShares - shares;
            totalAssets = currentTotalAssets - assetsOut;
        }
    }

    function donate(uint256 assets) external {
        if (assets == 0) revert ZeroAssets();
        if (totalShares == 0) revert NoShares();
        unchecked {
            totalAssets += assets;
        }
    }

    function previewDeposit(uint256 assets) external view returns (uint256 sharesMinted) {
        if (assets == 0) revert ZeroAssets();

        uint256 currentTotalShares = totalShares;
        if (currentTotalShares == 0) {
            return assets;
        }

        sharesMinted = (assets * currentTotalShares) / totalAssets;
        if (sharesMinted == 0) revert ZeroShares();
    }

    function previewWithdraw(uint256 assets) external view returns (uint256 sharesBurned) {
        if (assets == 0) revert ZeroAssets();
        return _previewWithdraw(assets, totalShares, totalAssets);
    }

    function previewRedeem(uint256 shares) external view returns (uint256 assetsOut) {
        if (shares == 0) revert ZeroShares();
        assetsOut = _previewRedeem(shares, totalShares, totalAssets);
        if (assetsOut == 0) revert ZeroAssets();
    }

    function _previewWithdraw(uint256 assets, uint256 currentTotalShares, uint256 currentTotalAssets)
        internal
        pure
        returns (uint256 sharesBurned)
    {
        uint256 numerator = assets * currentTotalShares;
        sharesBurned = numerator / currentTotalAssets;
        if (numerator % currentTotalAssets != 0) {
            unchecked {
                ++sharesBurned;
            }
        }
        if (sharesBurned == 0) revert ZeroShares();
    }

    function _previewRedeem(uint256 shares, uint256 currentTotalShares, uint256 currentTotalAssets)
        internal
        pure
        returns (uint256 assetsOut)
    {
        assetsOut = (shares * currentTotalAssets) / currentTotalShares;
    }
}
