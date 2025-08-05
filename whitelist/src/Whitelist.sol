// SPDX-License-Indentifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Whitelist
 * @dev A Merkle Tree-based whitelist contract that can be used by other contracts
 * to verfiy if an address is whitelisted
 */
contract Whitelist is Ownable {
    bytes32 public merkleRoot;

    event MerkleRootUpdated(bytes32 indexed oldRoot, bytes32 indexed newRoot);

    constructor(bytes32 _merkleRoot) Ownable(msg.sender) {
        merkleRoot = _merkleRoot;
    }

    /**
     * @dev Updates the Merkle root (only owner)
     * @param _newMerkleRoot The new Merkle root
     */

    function updateMerkleRoot(bytes32 _newMerkleRoot) external onlyOwner {
        bytes32 oldRoot = merkleRoot;
        merkleRoot = _newMerkleRoot;
        emit MerkleRootUpdated(oldRoot, _newMerkleRoot);
    }

    /**
     * @dev Verifies if an address is whitelisted
     * @param _address The address to verify
     * @param _merkleProof The Merkle proof for the address
     * @return bool True if the address is whitelisted
     */
    function isWhitelisted(
        address _address,
        bytes32[] calldata _merkleProof
    ) external view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(_address));

        return MerkleProof.verify(_merkleProof, merkleRoot, leaf);
    }

    /**
     * @dev Internal function to verify whitelist (for use by other contracts)
     * @param _address The address to verify
     * @param _merkleProof The Merkle proof for the address
     */
    function _verifyWhitelist(
        address _address,
        bytes32[] calldata _merkleProof
    ) internal view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(_address));

        return MerkleProof.verify(_merkleProof, merkleRoot, leaf);
    }
}
