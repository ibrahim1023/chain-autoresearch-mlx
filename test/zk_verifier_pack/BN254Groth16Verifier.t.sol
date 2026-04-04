// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../contracts/zk_verifier_pack/BN254Groth16Verifier.sol";
import "./ZKVerifierFixtures.sol";

contract BN254Groth16VerifierTest {
    BN254Groth16Verifier internal verifier;

    function setUp() public {
        verifier = new BN254Groth16Verifier();
    }

    function testVerifyProofAcceptsValidCaseA() public {
        ZKVerifierFixtures.ValidFixture memory fixture = ZKVerifierFixtures.validCaseA();
        require(
            verifier.verifyProof(fixture.publicInputs, fixture.proofA, fixture.proofB, fixture.proofC),
            "valid case A rejected"
        );
    }

    function testVerifyProofAcceptsValidCaseB() public {
        ZKVerifierFixtures.ValidFixture memory fixture = ZKVerifierFixtures.validCaseB();
        require(
            verifier.verifyProof(fixture.publicInputs, fixture.proofA, fixture.proofB, fixture.proofC),
            "valid case B rejected"
        );
    }
}
