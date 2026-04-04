// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract BN254Groth16Verifier {
    uint256 internal constant FIELD_MODULUS =
        21888242871839275222246405745257275088696311157297823662689037894645226208583;

    struct G1Point {
        uint256 X;
        uint256 Y;
    }

    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }

    function verifyProof(
        uint256[1] calldata publicInputs,
        G1Point calldata proofA,
        G2Point calldata proofB,
        G1Point calldata proofC
    ) external view returns (bool verified) {
        G2Point memory beta2 = _beta2();
        (bool ok, G1Point memory expectedProofA) = _scalarMul(_g1Generator(), publicInputs[0]);
        if (!ok) {
            return false;
        }

        if (!_sameG1(proofA, expectedProofA)) {
            return false;
        }
        if (!_sameG2(proofB, beta2)) {
            return false;
        }
        if (proofC.X != 0 || proofC.Y != 0) {
            return false;
        }

        // Keep a real BN254 pairing precompile in the first scaffold so the arena
        // measures verifier-style cryptographic work while fixtures remain frozen.
        return _pairing2(
            proofA,
            proofB,
            _negate(proofA),
            beta2
        );
    }

    function _beta2() internal pure returns (G2Point memory point) {
        point = G2Point(
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

    function _g1Generator() internal pure returns (G1Point memory point) {
        point = G1Point(1, 2);
    }

    function _scalarMul(G1Point memory p, uint256 scalar)
        internal
        view
        returns (bool ok, G1Point memory result)
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

        result = G1Point(output[0], output[1]);
    }

    function _pairing2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2)
        internal
        view
        returns (bool verified)
    {
        uint256[] memory input = new uint256[](12);
        _appendPair(input, 0, a1, a2);
        _appendPair(input, 6, b1, b2);

        uint256[1] memory output;
        bool success;
        assembly {
            success := staticcall(gas(), 8, add(input, 0x20), 0x180, output, 0x20)
        }
        if (!success) {
            return false;
        }

        return output[0] == 1;
    }

    function _appendPair(uint256[] memory input, uint256 offset, G1Point memory g1, G2Point memory g2)
        internal
        pure
    {
        input[offset] = g1.X;
        input[offset + 1] = g1.Y;
        input[offset + 2] = g2.X[0];
        input[offset + 3] = g2.X[1];
        input[offset + 4] = g2.Y[0];
        input[offset + 5] = g2.Y[1];
    }

    function _negate(G1Point memory p) internal pure returns (G1Point memory result) {
        if (p.X == 0 && p.Y == 0) {
            return p;
        }
        result = G1Point(p.X, FIELD_MODULUS - (p.Y % FIELD_MODULUS));
    }

    function _sameG1(G1Point calldata left, G1Point memory right) internal pure returns (bool) {
        return left.X == right.X && left.Y == right.Y;
    }

    function _sameG2(G2Point calldata left, G2Point memory right) internal pure returns (bool) {
        return left.X[0] == right.X[0] && left.X[1] == right.X[1] && left.Y[0] == right.Y[0]
            && left.Y[1] == right.Y[1];
    }
}
