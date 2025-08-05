import { MerkleTree } from "merkletreejs";
import keccak256 from "keccak256";

// Whitelist addresses
const addresses = [
  // dummy address for testing
  "0x742D35cC6634c0532925a3b8d7C95a7d4D5c6E7f",
  "0x8Ba1f109551bD432803012645AaC136C86BB1A0F",
  "0xdd2fD4581271E230360230f9337d5c0434068c13",
  // Add more addresses as needed
];

// Create leaves by hashing addresses
const leaves = addresses.map((addr) => keccak256(addr));

// Create Merkle tree
const merkleTree = new MerkleTree(leaves, keccak256, { sortPairs: true });

// Get Merkle root
const merkleRoot = merkleTree.getHexRoot();

console.log("Merkle Root:", merkleRoot);
console.log("\nProofs:");

// Generate proofs for each address
addresses.forEach((address, index) => {
  const leaf = keccak256(address);
  const proof = merkleTree.getHexProof(leaf);
  console.log(`${address}: [${proof.map((p) => `"${p}"`).join(", ")}]`);
});
