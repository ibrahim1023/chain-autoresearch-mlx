// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../contracts/GasCandidate.sol";

contract GasCandidateTest {
    GasCandidate internal candidate;
    address[] internal accounts;
    uint256[] internal scores;

    function setUp() public {
        candidate = new GasCandidate();
        accounts = new address[](3);
        scores = new uint256[](3);

        accounts[0] = address(0x1001);
        accounts[1] = address(0x1002);
        accounts[2] = address(0x1003);

        scores[0] = 10;
        scores[1] = 20;
        scores[2] = 30;
    }

    function testRegisterBatchAddsUniqueMembers() public {
        uint256 added = candidate.registerBatch(accounts);
        require(added == 3, "expected all members to be added");
        require(candidate.memberCount() == 3, "wrong member count");

        added = candidate.registerBatch(accounts);
        require(added == 0, "expected duplicates to be ignored");
        require(candidate.memberCount() == 3, "member count changed unexpectedly");
    }

    function testSetScoresTracksTotalScore() public {
        candidate.registerBatch(accounts);
        uint256 appliedTotal = candidate.setScores(accounts, scores);

        require(appliedTotal == 60, "wrong applied total");
        require(candidate.totalScore() == 60, "wrong total score");
        require(candidate.scores(accounts[0]) == 10, "wrong first score");
        require(candidate.scores(accounts[2]) == 30, "wrong third score");
    }

    function testSetScoresRevertsOnLengthMismatch() public {
        candidate.registerBatch(accounts);

        uint256[] memory shortScores = new uint256[](2);
        shortScores[0] = 1;
        shortScores[1] = 2;

        (bool ok,) = address(candidate).call(
            abi.encodeWithSelector(candidate.setScores.selector, accounts, shortScores)
        );
        require(!ok, "expected length mismatch to revert");
    }

    function testBumpAllUpdatesScoresAndTotal() public {
        candidate.registerBatch(accounts);
        candidate.setScores(accounts, scores);

        uint256 updated = candidate.bumpAll(5);

        require(updated == 3, "wrong updated count");
        require(candidate.totalScore() == 75, "wrong bumped total");
        require(candidate.scores(accounts[0]) == 15, "wrong bumped score");
        require(candidate.scores(accounts[2]) == 35, "wrong bumped score");
    }
}
