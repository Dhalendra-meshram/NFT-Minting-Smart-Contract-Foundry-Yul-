// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/NftMinting.sol";

contract NftMintingTest is Test {
    NftMinting nft;
    address user = address(0x1);

    function setUp() public {
        nft = new NftMinting(bytes32(0));
        nft.togglePublicSale();
        vm.deal(user, 1 ether);
    }

    function testPublicMint() public {
        vm.prank(user);
        nft.publicSaleMint{value: 0.01 ether}(1, _cidArray(1));
        assertEq(nft.ownerOf(0), user);
    }

    // Updated from testFailWrongPayment
    function test_RevertWhenWrongPayment() public {
        vm.prank(user);
        // Raw YUL selector from _validatePayment
        vm.expectRevert(bytes4(0x7c1e5b10));
        nft.publicSaleMint{value: 0}(1, _cidArray(1));
    }

    function testFuzzMint(uint256 amount) public {
        vm.assume(amount > 0 && amount < 5);
        vm.deal(user, amount * 0.01 ether);

        vm.prank(user);
        nft.publicSaleMint{value: amount * 0.01 ether}(amount, _cidArray(amount));

        assertEq(nft.totalSupply(), amount);
    }

    function _cidArray(uint256 n) internal pure returns (string[] memory arr) {
        arr = new string[](n);
        for (uint256 i; i < n; i++) {
            arr[i] = "cid";
        }
    }
}
