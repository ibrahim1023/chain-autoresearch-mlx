// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../contracts/zk_verifier_pack/BN254Groth16Verifier.sol";
import "./ZKVerifierFixtures.sol";

contract ZKVerifierPackBenchmarkTest {
    BN254Groth16Verifier internal verifier;
    ZKVerifierFixtures.ValidFixture internal validA;
    ZKVerifierFixtures.ValidFixture internal validB;

    function setUp() public {
        verifier = new BN254Groth16Verifier();
        validA = ZKVerifierFixtures.validCaseA();
        validB = ZKVerifierFixtures.validCaseB();
    }

    function testGasBN254Groth16VerifierValidCaseA() public {
        require(
            verifier.verifyProof(validA.publicInputs, validA.proofA, validA.proofB, validA.proofC),
            "valid case A rejected"
        );
    }

    function testGasBN254Groth16VerifierValidCaseB() public {
        require(
            verifier.verifyProof(validB.publicInputs, validB.proofA, validB.proofB, validB.proofC),
            "valid case B rejected"
        );
    }
}
