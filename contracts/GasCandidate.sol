// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract GasCandidate {
    error LengthMismatch();

    mapping(address => bool) public registered;
    mapping(address => uint256) public scores;
    address[] internal members;
    uint256 public totalScore;

    function registerBatch(address[] calldata accounts) external returns (uint256 added) {
        uint256 len = accounts.length;
        for (uint256 i = 0; i < len; ++i) {
            address account = accounts[i];
            if (!registered[account]) {
                registered[account] = true;
                members.push(account);
                added += 1;
            }
        }
    }

    function setScores(address[] calldata accounts, uint256[] calldata newScores)
        external
        returns (uint256 appliedTotal)
    {
        uint256 len = accounts.length;
        if (len != newScores.length) {
            revert LengthMismatch();
        }

        uint256 runningTotal = totalScore;
        for (uint256 i = 0; i < len; ++i) {
            address account = accounts[i];
            uint256 oldScore = scores[account];
            uint256 newScore = newScores[i];
            scores[account] = newScore;
            runningTotal = runningTotal - oldScore + newScore;
            appliedTotal += newScore;
        }
        totalScore = runningTotal;
    }

    function bumpAll(uint256 amount) external returns (uint256 updated) {
        uint256 len = members.length;
        uint256 runningTotal = totalScore;
        for (uint256 i = 0; i < len; ++i) {
            address account = members[i];
            scores[account] += amount;
            runningTotal += amount;
            updated += 1;
        }
        totalScore = runningTotal;
    }

    function memberCount() external view returns (uint256) {
        return members.length;
    }
}
