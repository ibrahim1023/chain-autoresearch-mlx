// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../contracts/zk_verifier_pack/BN254Groth16Comparator.sol";
import "./ZKVerifierFixtures.sol";

contract BN254Groth16ComparatorBenchmarkTest {
    BN254Groth16Comparator internal comparator;
    ZKVerifierFixtures.ValidFixture internal validA;
    ZKVerifierFixtures.ValidFixture internal validB;

    function setUp() public {
        comparator = new BN254Groth16Comparator();
        validA = ZKVerifierFixtures.validCaseA();
        validB = ZKVerifierFixtures.validCaseB();
    }

    function testGasBN254Groth16ComparatorValidCaseA() public {
        require(
            comparator.verifyProof(validA.publicInputs, validA.proofA, validA.proofB, validA.proofC),
            "valid case A rejected"
        );
    }

    function testGasBN254Groth16ComparatorValidCaseB() public {
        require(
            comparator.verifyProof(validB.publicInputs, validB.proofA, validB.proofB, validB.proofC),
            "valid case B rejected"
        );
    }
}
