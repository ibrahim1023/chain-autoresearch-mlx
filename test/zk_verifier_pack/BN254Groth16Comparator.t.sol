// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../contracts/zk_verifier_pack/BN254Groth16Comparator.sol";
import "./ZKVerifierFixtures.sol";

contract BN254Groth16ComparatorTest {
    BN254Groth16Comparator internal comparator;

    function setUp() public {
        comparator = new BN254Groth16Comparator();
    }

    function testVerifyProofAcceptsValidCaseA() public {
        ZKVerifierFixtures.ValidFixture memory fixture = ZKVerifierFixtures.validCaseA();
        require(
            comparator.verifyProof(fixture.publicInputs, fixture.proofA, fixture.proofB, fixture.proofC),
            "valid case A rejected"
        );
    }

    function testVerifyProofAcceptsValidCaseB() public {
        ZKVerifierFixtures.ValidFixture memory fixture = ZKVerifierFixtures.validCaseB();
        require(
            comparator.verifyProof(fixture.publicInputs, fixture.proofA, fixture.proofB, fixture.proofC),
            "valid case B rejected"
        );
    }
}
