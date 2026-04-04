// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../contracts/zk_verifier_pack/BN254Groth16Comparator.sol";
import "./ZKVerifierFixtures.sol";

contract BN254Groth16ComparatorRejectionTest {
    BN254Groth16Comparator internal comparator;

    function setUp() public {
        comparator = new BN254Groth16Comparator();
    }

    function testVerifyProofRejectsWrongPublicInputs() public {
        ZKVerifierFixtures.InvalidFixture memory fixture = ZKVerifierFixtures.invalidWrongPublicInputs();
        bool verified = comparator.verifyProof(fixture.publicInputs, fixture.proofA, fixture.proofB, fixture.proofC);
        require(!verified, "wrong public inputs accepted");
    }

    function testVerifyProofRejectsCorruptedProof() public {
        ZKVerifierFixtures.InvalidFixture memory fixture = ZKVerifierFixtures.invalidCorruptedProof();
        bool verified = comparator.verifyProof(fixture.publicInputs, fixture.proofA, fixture.proofB, fixture.proofC);
        require(!verified, "corrupted proof accepted");
    }

    function testVerifyProofRejectsMalformedProofLayout() public {
        ZKVerifierFixtures.InvalidFixture memory fixture = ZKVerifierFixtures.invalidMalformedLayout();
        (bool ok,) = address(comparator).call(fixture.malformedCalldata);
        require(!ok, "malformed proof layout accepted");
    }
}
