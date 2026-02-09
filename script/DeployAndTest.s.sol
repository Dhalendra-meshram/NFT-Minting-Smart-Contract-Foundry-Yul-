// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import "../src/NftMinting.sol";

contract DeployAndTest is Script {
    function run() external {
        // Start broadcasting transactions (for real deployment)
        vm.startBroadcast();

        // Deploy the NFT contract
        // Pass an empty merkle root for now
        NftMinting nft = new NftMinting(bytes32(0));

        // Optionally enable public sale
        nft.togglePublicSale();

        // Print deployed contract address
        console.log("NFT contract deployed at:", address(nft));

        // Stop broadcasting
        vm.stopBroadcast();
    }
}
