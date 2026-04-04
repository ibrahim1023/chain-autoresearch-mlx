// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../contracts/zk_verifier_pack/BN254Groth16Verifier.sol";
import "./ZKVerifierFixtures.sol";

contract BN254Groth16VerifierRejectionTest {
    BN254Groth16Verifier internal verifier;

    function setUp() public {
        verifier = new BN254Groth16Verifier();
    }

    function testVerifyProofRejectsWrongPublicInputs() public {
        ZKVerifierFixtures.InvalidFixture memory fixture = ZKVerifierFixtures.invalidWrongPublicInputs();
        bool verified = verifier.verifyProof(fixture.publicInputs, fixture.proofA, fixture.proofB, fixture.proofC);
        require(!verified, "wrong public inputs accepted");
    }

    function testVerifyProofRejectsCorruptedProof() public {
        ZKVerifierFixtures.InvalidFixture memory fixture = ZKVerifierFixtures.invalidCorruptedProof();
        bool verified = verifier.verifyProof(fixture.publicInputs, fixture.proofA, fixture.proofB, fixture.proofC);
        require(!verified, "corrupted proof accepted");
    }

    function testVerifyProofRejectsMalformedProofLayout() public {
        ZKVerifierFixtures.InvalidFixture memory fixture = ZKVerifierFixtures.invalidMalformedLayout();
        (bool ok,) = address(verifier).call(fixture.malformedCalldata);
        require(!ok, "malformed proof layout accepted");
    }
}
