// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../contracts/zk_verifier_pack/BN254Groth16Verifier.sol";

library ZKVerifierFixtures {
    enum InvalidCategory {
        WrongPublicInputs,
        CorruptedProof,
        MalformedLayout
    }

    struct ValidFixture {
        uint256[1] publicInputs;
        BN254Groth16Verifier.G1Point proofA;
        BN254Groth16Verifier.G2Point proofB;
        BN254Groth16Verifier.G1Point proofC;
    }

    struct InvalidFixture {
        InvalidCategory category;
        uint256[1] publicInputs;
        BN254Groth16Verifier.G1Point proofA;
        BN254Groth16Verifier.G2Point proofB;
        BN254Groth16Verifier.G1Point proofC;
        bytes malformedCalldata;
    }

    function verifyingKey() internal pure returns (BN254Groth16Verifier.VerifyingKey memory vk) {
        vk.alpha1 = BN254Groth16Verifier.G1Point(0, 0);
        vk.beta2 = BN254Groth16Verifier.G2Point(
            [
                11559732032986387107991004021392285783925812861821192530917403151452391805634,
                10857046999023057135944570762232829481370756359578518086990519993285655852781
            ],
            [
                4082367875863433681332203403145435568316851327593401208105741076214120093531,
                8495653923123431417604973247489272438418190587263600148770280649306958101930
            ]
        );
        vk.gamma2 = vk.beta2;
        vk.delta2 = vk.beta2;
        vk.ic0 = BN254Groth16Verifier.G1Point(0, 0);
        vk.ic1 = BN254Groth16Verifier.G1Point(1, 2);
    }

    function validCaseA() internal pure returns (ValidFixture memory fixture) {
        fixture.publicInputs[0] = 1;
        fixture.proofA = _g1Generator();
        fixture.proofB = _g2Generator();
        fixture.proofC = BN254Groth16Verifier.G1Point(0, 0);
    }

    function validCaseB() internal view returns (ValidFixture memory fixture) {
        fixture.publicInputs[0] = 2;
        fixture.proofA = _scalarMul(_g1Generator(), 2);
        fixture.proofB = _g2Generator();
        fixture.proofC = BN254Groth16Verifier.G1Point(0, 0);
    }

    function invalidWrongPublicInputs() internal pure returns (InvalidFixture memory fixture) {
        ValidFixture memory valid = validCaseA();
        fixture.category = InvalidCategory.WrongPublicInputs;
        fixture.publicInputs[0] = 2;
        fixture.proofA = valid.proofA;
        fixture.proofB = valid.proofB;
        fixture.proofC = valid.proofC;
    }

    function invalidCorruptedProof() internal pure returns (InvalidFixture memory fixture) {
        ValidFixture memory valid = validCaseA();
        fixture.category = InvalidCategory.CorruptedProof;
        fixture.publicInputs[0] = valid.publicInputs[0];
        fixture.proofA = BN254Groth16Verifier.G1Point(0, 0);
        fixture.proofB = valid.proofB;
        fixture.proofC = valid.proofC;
    }

    function invalidMalformedLayout() internal pure returns (InvalidFixture memory fixture) {
        fixture.category = InvalidCategory.MalformedLayout;
        fixture.malformedCalldata = abi.encodePacked(
            BN254Groth16Verifier.verifyProof.selector,
            uint256(1)
        );
    }

    function _g2Generator() private pure returns (BN254Groth16Verifier.G2Point memory) {
        return BN254Groth16Verifier.G2Point(
            [
                11559732032986387107991004021392285783925812861821192530917403151452391805634,
                10857046999023057135944570762232829481370756359578518086990519993285655852781
            ],
            [
                4082367875863433681332203403145435568316851327593401208105741076214120093531,
                8495653923123431417604973247489272438418190587263600148770280649306958101930
            ]
        );
    }

    function _g1Generator() private pure returns (BN254Groth16Verifier.G1Point memory) {
        return BN254Groth16Verifier.G1Point(1, 2);
    }

    function _scalarMul(BN254Groth16Verifier.G1Point memory point, uint256 scalar)
        private
        view
        returns (BN254Groth16Verifier.G1Point memory result)
    {
        uint256[] memory input = new uint256[](3);
        input[0] = point.X;
        input[1] = point.Y;
        input[2] = scalar;

        uint256[2] memory output;
        bool ok;
        assembly {
            ok := staticcall(gas(), 7, add(input, 0x20), 0x60, output, 0x40)
        }
        require(ok, "fixture scalar mul failed");
        result = BN254Groth16Verifier.G1Point(output[0], output[1]);
    }
}
