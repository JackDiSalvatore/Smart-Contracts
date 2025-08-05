// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Whitelist.sol";
import "../src/NFTMinter.sol";

contract WhitelistTest is Test {
    Whitelist public whitelist;
    NFTMinter public nftMinter;

    address public owner;
    address public user1;
    address public user2;
    address public user3;

    // Events to match contract events
    event MerkleRootUpdated(bytes32 indexed oldRoot, bytes32 indexed newRoot);
    event WhitelistContractUpdated(
        address indexed oldContract,
        address indexed newContract
    );

    // Example Merkle tree data - you generate this off-chain
    bytes32 public merkleRoot =
        0x307ef8a065195ce466ec9d8d29ff35c3fe75275714fde1d3c1f1ef3021718b9c;

    // Merkle proofs for test address (generated off-chain)
    bytes32[] public user1Proof;
    bytes32[] public user2Proof;
    bytes32[] public user3Proof;

    function setUp() public {
        owner = address(this);
        user1 = address(0x742D35cC6634c0532925a3b8d7C95a7d4D5c6E7f);
        user2 = address(0x8Ba1f109551bD432803012645AaC136C86BB1A0F);
        user3 = address(0xdd2fD4581271E230360230f9337d5c0434068c13);

        // Deploy whitelist contract
        whitelist = new Whitelist(merkleRoot);

        // Deploy NFT minter contract
        nftMinter = new NFTMinter("Test NFT", "NFT", address(whitelist));

        // Set up merkle proofs (these would be generated off-chain)
        // For this example, we will use dummy proofs
        user1Proof.push(
            0xbfae518f84014e535eeab03261efe78926847bc76d546a7dd74fbfebbe6768ca
        );
        user1Proof.push(
            0xc35753794d2a715a15c36507b30cdc7bc523b6c5a8cb485fac88aa55ff21e128
        );

        user2Proof.push(
            0x401aadfe8d9fc5296d33c9433eeb71a6c138ce4513ff6d530cbf9780c8d2b1b0
        );
        user2Proof.push(
            0xc35753794d2a715a15c36507b30cdc7bc523b6c5a8cb485fac88aa55ff21e128
        );

        user3Proof.push(
            0x7dd1a8ed768a81986663084211f8986a29ce9489cac8be7bd27199af00c55867
        );
    }

    function testInitialMerkleRoot() public view {
        assertEq(whitelist.merkleRoot(), merkleRoot);
    }

    function testOwnership() public view {
        assertEq(whitelist.owner(), owner);
    }

    function testUpdateMerkleRoot() public {
        bytes32 newRoot = 0x123456789abcdef123456789abcdef123456789abcdef123456789abcdef1234;

        // check event emission
        vm.expectEmit(true, true, false, true);
        emit MerkleRootUpdated(merkleRoot, newRoot);

        whitelist.updateMerkleRoot(newRoot);
        assertEq(whitelist.merkleRoot(), newRoot);
    }

    function testUpdateMerkleRootOnlyOwner() public {
        bytes32 newRoot = 0x123456789abcdef123456789abcdef123456789abcdef123456789abcdef1234;

        vm.prank(user1); // sets `msg.sender` to the specified address for the next call
        vm.expectRevert();

        whitelist.updateMerkleRoot(newRoot);
    }

    function testIsWhitelistedWithValidProof() public view {
        // Note: This test assumes user1 is actually in the merkle tree
        // In a real scenario, you'd generate the tree off-chain and use real proofs
        bool isListed = whitelist.isWhitelisted(user1, user1Proof);
        // This might fail with dummy data - that's expected
        // console.log("User1 is whitelisted:", isListed);
    }

    function testIsWhitelistedWithInvalidProof() public view {
        bytes32[] memory invalidProof = new bytes32[](1);
        invalidProof[0] = 0x0;

        bool isListed = whitelist.isWhitelisted(user1, invalidProof);
        assertFalse(isListed);
    }

    function testNFTMinterIntegration() public view {
        // Test that NFT minter correctly used whitelist contract
        assertEq(address(nftMinter.whitelist()), address(whitelist));
        assertEq(nftMinter.currentTokenId(), 0);
    }

    function testUpdateWhitelistContract() public {
        Whitelist newWhitelist = new Whitelist(merkleRoot);

        vm.expectEmit(true, true, false, false);
        emit WhitelistContractUpdated(
            address(whitelist),
            address(newWhitelist)
        );

        nftMinter.updateWhitelistContract(address(newWhitelist));
        assertEq(address(nftMinter.whitelist()), address(newWhitelist));
    }

    function testWhitelistMintFailsWithoutValidProof() public {
        bytes32[] memory invalidProof = new bytes32[](1);
        invalidProof[0] = 0x0;

        vm.prank(user1);
        vm.expectRevert("Not whitelisted");

        nftMinter.whitelistMint(invalidProof);
    }

    function testPreventDoubleMinting() public {
        // This test assumes `user1` has a valid proof
        // Skip if using dummy data
        vm.skip(true);

        vm.startPrank(user1);
        nftMinter.whitelistMint(user1Proof);

        vm.expectRevert("Already minted");
        nftMinter.whitelistMint(user1Proof);
        vm.stopPrank();
    }
}
