// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Whitelist.sol";
import "../src/NFTMinter.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Replace with your actual Merkle root
        bytes32 merkleRoot = 0x2e174c10e159ea99b867ce3205125c24a42d128804e4070ed6fcc8cc98166aa0;

        // Deploy Whitelist contract
        Whitelist whitelist = new Whitelist(merkleRoot);
        console.log("Whitelist deployed at:", address(whitelist));

        // Deploy NFT Minter contract
        NFTMinter nftMinter = new NFTMinter(
            "Presale NFT",
            "PNFT",
            address(whitelist)
        );

        console.log("NFT Minter deployed at:", address(nftMinter));

        vm.stopBroadcast();
    }
}
