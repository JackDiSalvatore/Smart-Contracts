# Whitelist

A Solidity Whitelist smart contract.

Example use cases:

- Whitelist user addresses. Can be used for token sales, etc.

**Implementation:**

To save on gas, this Smart Contract utilizes a Merkle Tree and Merkle Proof to validate if a user has been added to a whitelist. The whitelist must be pre-computed and saved on the Smart Contract before it can be used.

Steps:

1. Compute Merkle Root
2. Deploy Contract + set Merkle Root
3. Users can compute a Merkle Proof and interact with contract

**Install**

```shell
# Smart Contract
forge install OpenZeppelin/openzeppelin-contracts

# JavaScript
npm i
```

**Tests**

Generate your test Merkle Tree off-chain

Change the address values in the `scripts/generateMerkleTree.js`

```shell
node script/generateMerkleTree.js
```

Change the address values in the tests `tests/Whitelist.t.sol`

Run smart contract test.

```shell
forge test -vvv

forge test --match-test testUpdateMerkleRoot

forge test --gas-report
```

**Generate Merkle Root and Proofs (script)**

Generate the Merkle Tree off-chain. You should modify the whitelist addresses with real accounts.

```shell
node script/generateMerkleTree.js
```

**Deploy**

```shell
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast --verify
```

**Static Analyzer**

Assuming slither is installed

```shell
slither src/Whitelist.sol
```

## Key Features

1. Merkle Tree Verification: Uses OpenZeppelin's MerkleProof library for gas-efficient whitelist verification
2. Admin Controls: Only the contract owner can update the Merkle root
3. Modular Design: Other contracts can easily integrate with the whitelist
4. Gas Efficient: Merkle trees allow for O(log n) verification complexity
5. Flexible: Merkle root can be updated to add/remove addresses from whitelist

## Best Practices

1. Generate Merkle trees off-chain to save gas
2. Store the Merkle tree data securely for proof generation
3. Consider using IPFS to store the full whitelist for transparency
4. Implement proper access controls for administrative functions
5. Add events for important state changes for better observability

This implementation provides a solid foundation for a whitelist system that can be used across multiple contracts while maintaining security and gas efficiency.

## Example Use Cases

There are many practical use case for a merkle tree whitelist in decentrialzed applications (just ask Chat-GPT or Claude), but consider the following. The beauty of the Merkle tree approach is its flexibility - you can encode not just addresses but additional metadata like access levels, expiration dates, or specific permissions within the leaf nodes, making it adaptable to virtually any access control scenario.
