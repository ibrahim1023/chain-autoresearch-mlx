// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./BN254Groth16Verifier.sol";

contract BN254Groth16Comparator {
    function verifyProof(
        uint256[1] calldata publicInputs,
        BN254Groth16Verifier.G1Point calldata proofA,
        BN254Groth16Verifier.G2Point calldata proofB,
        BN254Groth16Verifier.G1Point calldata proofC
    ) external view returns (bool verified) {
        if (proofC.X != 0 || proofC.Y != 0) {
            return false;
        }

        if (!_sameG2(proofB, _beta2())) {
            return false;
        }

        (bool ok, BN254Groth16Verifier.G1Point memory expectedProofA) =
            _scalarMul(_g1Generator(), publicInputs[0]);
        if (!ok) {
            return false;
        }

        return _sameG1(proofA, expectedProofA);
    }

    function _beta2() internal pure returns (BN254Groth16Verifier.G2Point memory point) {
        point = BN254Groth16Verifier.G2Point(
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

    function _g1Generator() internal pure returns (BN254Groth16Verifier.G1Point memory point) {
        point = BN254Groth16Verifier.G1Point(1, 2);
    }

    function _scalarMul(BN254Groth16Verifier.G1Point memory p, uint256 scalar)
        internal
        view
        returns (bool ok, BN254Groth16Verifier.G1Point memory result)
    {
        uint256[] memory input = new uint256[](3);
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = scalar;

        uint256[2] memory output;
        assembly {
            ok := staticcall(gas(), 7, add(input, 0x20), 0x60, output, 0x40)
        }
        if (!ok) {
            return (false, result);
        }

        result = BN254Groth16Verifier.G1Point(output[0], output[1]);
    }

    function _sameG1(BN254Groth16Verifier.G1Point calldata left, BN254Groth16Verifier.G1Point memory right)
        internal
        pure
        returns (bool)
    {
        return left.X == right.X && left.Y == right.Y;
    }

    function _sameG2(BN254Groth16Verifier.G2Point calldata left, BN254Groth16Verifier.G2Point memory right)
        internal
        pure
        returns (bool)
    {
        return left.X[0] == right.X[0] && left.X[1] == right.X[1] && left.Y[0] == right.Y[0]
            && left.Y[1] == right.Y[1];
    }
}
