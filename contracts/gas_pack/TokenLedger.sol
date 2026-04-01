// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract TokenLedger {
    error LengthMismatch();
    error ZeroAddress();
    error InsufficientBalance();

    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply;

    function mintBatch(address[] calldata accounts, uint256[] calldata amounts) external returns (uint256 minted) {
        uint256 length = accounts.length;
        if (length != amounts.length) revert LengthMismatch();

        for (uint256 i = 0; i < length;) {
            address account;
            uint256 amount;
            assembly {
                account := calldataload(add(accounts.offset, shl(5, i)))
                amount := calldataload(add(amounts.offset, shl(5, i)))
            }

            if (account == address(0)) revert ZeroAddress();

            balanceOf[account] += amount;
            minted += amount;

            unchecked {
                ++i;
            }
        }

        totalSupply += minted;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        if (to == address(0)) revert ZeroAddress();

        uint256 fromBalance = balanceOf[msg.sender];
        if (fromBalance < amount) revert InsufficientBalance();

        unchecked {
            balanceOf[msg.sender] = fromBalance - amount;
        }
        balanceOf[to] += amount;
        return true;
    }

    function burn(uint256 amount) external returns (bool) {
        uint256 fromBalance = balanceOf[msg.sender];
        if (fromBalance < amount) revert InsufficientBalance();

        unchecked {
            balanceOf[msg.sender] = fromBalance - amount;
            totalSupply -= amount;
        }
        return true;
    }
}
