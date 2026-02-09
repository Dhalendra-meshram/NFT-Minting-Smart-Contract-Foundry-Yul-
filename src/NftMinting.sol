// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "solmate/tokens/ERC721.sol";
import "solmate/auth/Owned.sol";
import "solmate/utils/ReentrancyGuard.sol";
import "merkle/MerkleProof.sol";

contract NftMinting is ERC721, Owned, ReentrancyGuard {
    // CONSTANTS

    uint256 public constant MAX_SUPPLY = 20;
    uint256 public constant MINT_PRICE = 0.01 ether;
    uint256 public constant PRESALE_LIMIT = 5;

    // STORAGES
    bytes32 public immutable MERKLE_ROOT;

    bool public paused;
    bool public presaleActive;
    bool public publicSaleActive;

    uint256 public currentTokenId;

    mapping(address => uint256) public presaleMinted;
    mapping(uint256 => string) public tokenCids;

    // ERRORS
    error SaleNotActive();
    error InvalidPayment();
    error MaxSupplyExceeded();
    error PresaleLimitExceeded();
    error InvalidMerkleProof();

    // CONSTRUCTOR
    constructor(bytes32 _merkleRoot) ERC721("NEW NFT", "NNT") Owned(msg.sender) {
        MERKLE_ROOT = _merkleRoot;
    }

    // SALE TOGGLES
    function togglePresale() external onlyOwner {
        presaleActive = !presaleActive;
    }

    function togglePublicSale() external onlyOwner {
        publicSaleActive = !publicSaleActive;
    }

    function setPaused(bool value) external onlyOwner {
        paused = value;
    }

    // PRESALE MINT
    function presaleMint(uint256 amount, bytes32[] calldata proof, string[] calldata cids)
        external
        payable
        nonReentrant
    {
        if (!presaleActive || !publicSaleActive) revert SaleNotActive();
        _verifyMerkle(proof);

        uint256 minted = presaleMinted[msg.sender];
        if (minted + amount > PRESALE_LIMIT) {
            revert PresaleLimitExceeded();
        }

        presaleMinted[msg.sender] = minted + amount;
        _mintInternal(amount, cids);
    }

    // PUBLIC MINT
    function publicSaleMint(uint256 amount, string[] calldata cids) external payable nonReentrant {
        if (paused || !publicSaleActive) revert SaleNotActive();
        _mintInternal(amount, cids);
    }

    // INTERNAL MINT (YUL HEAVY)
    function _mintInternal(uint256 amount, string[] calldata cids) internal {
        _validatePayment(amount);

        assembly {
            let supply := sload(currentTokenId.slot)
            if gt(add(supply, amount), MAX_SUPPLY) {
                mstore(0x00, 0x3f2c3f38) // MaxSupplyExceeded()
                revert(0x1c, 0x04)
            }
        }

        if (cids.length != amount) revert();

        for (uint256 i; i < amount;) {
            uint256 tokenId;

            assembly {
                tokenId := sload(currentTokenId.slot)
                sstore(currentTokenId.slot, add(tokenId, 1))
            }

            _safeMint(msg.sender, tokenId);
            tokenCids[tokenId] = cids[i];

            unchecked {
                ++i;
            }
        }
    }

    // PAYMENT VALIDATION (YUL)
    function _validatePayment(uint256 amount) internal view {
        assembly {
            let required := mul(amount, MINT_PRICE)
            if iszero(eq(callvalue(), required)) {
                mstore(0x00, 0x7c1e5b10) // InvalidPayment()
                revert(0x1c, 0x04)
            }
        }
    }

    /// MERKLE VERIFICATION
    function _verifyMerkle(bytes32[] calldata proof) internal view {
        if (!MerkleProof.verify(proof, MERKLE_ROOT, keccak256(abi.encodePacked(msg.sender)))) {
            revert InvalidMerkleProof();
        }
    }

    // VIEWS
    function totalSupply() external view returns (uint256) {
        return currentTokenId;
    }

    function remainingSupply() external view returns (uint256) {
        return MAX_SUPPLY - currentTokenId;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return tokenCids[tokenId];
    }
}
