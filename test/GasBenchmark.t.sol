// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../contracts/GasCandidate.sol";

contract GasBenchmarkTest {
    address[] internal accounts16;
    uint256[] internal scores16;

    function setUp() public {
        accounts16 = new address[](16);
        scores16 = new uint256[](16);

        for (uint256 i = 0; i < 16; ++i) {
            accounts16[i] = address(uint160(0x2000 + i));
            scores16[i] = (i + 1) * 11;
        }
    }

    function testGasRegisterBatch16() public {
        GasCandidate candidate = new GasCandidate();
        candidate.registerBatch(accounts16);
    }

    function testGasSetScores16() public {
        GasCandidate candidate = new GasCandidate();
        candidate.registerBatch(accounts16);
        candidate.setScores(accounts16, scores16);
    }

    function testGasBumpAll16() public {
        GasCandidate candidate = new GasCandidate();
        candidate.registerBatch(accounts16);
        candidate.setScores(accounts16, scores16);
        candidate.bumpAll(7);
    }
}
