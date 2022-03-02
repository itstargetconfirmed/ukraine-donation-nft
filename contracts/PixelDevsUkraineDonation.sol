// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
// import "hardhat/console.sol";

/// @author Developer DAO
/// @title The Pixel Devs Ukraine Donation smart contract that is compliant to ERC721 standard.
contract PixelDevsUkraineDonation is ERC721Enumerable, ReentrancyGuard, Ownable {
    /// TODO: Set this to the IPFS base uri before launch
    string public baseURI =
        "ipfs://abcd.../";

    uint256 public minimumMintPrice = 12 ether;

    enum DonationType{ BRONZE, SILVER, GOLD, DIAMOND, PLATINUM }

    DonationType public donationType;

    event LogTokenMinted(address indexed minter, uint256 indexed tokenId, string indexed donationType);
    event BaseURIUpdated(string indexed oldValue, string indexed newValue);
    event MinimumMintPriceUpdated(uint256 indexed oldValue, uint256 indexed newValue);

    constructor() ERC721("PixelDevsUkraineDonation", "PXLDEV-UKRAINE") {
        // console.log("PixelDevsUkraineDonation deployed by '%s'", msg.sender);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        emit BaseURIUpdated(baseURI, _newBaseURI);
        baseURI = _newBaseURI;
    }

    function tokenURI(uint256 tokenID) public view override returns (string memory) {
        if (donationType == DonationType.BRONZE) {
            return string(bytes.concat(bytes(baseURI), bytes("bronze")));
        } else if (donationType == DonationType.SILVER) {
            return string(bytes.concat(bytes(baseURI), bytes("silver")));
        } else if (donationType == DonationType.GOLD) {
            return string(bytes.concat(bytes(baseURI), bytes("gold")));
        } else if (donationType == DonationType.DIAMOND) {
            return string(bytes.concat(bytes(baseURI), bytes("diamond")));
        } else if (donationType == DonationType.PLATINUM) {
            return string(bytes.concat(bytes(baseURI), bytes("platinum")));
        }
        return Strings.toString(tokenID);
    }

    function setMinimumMintPrice(uint256 _newPrice) public onlyOwner {
        // Mint price in wei
        emit MinimumMintPriceUpdated(minimumMintPrice, _newPrice);
        minimumMintPrice = _newPrice;
    }

    function mint(
        uint256 tokenId
    )
        public
        payable
        nonReentrant
    {
        require(minimumMintPrice <= msg.value, "Not enough MATIC sent");
        _safeMint(msg.sender, tokenId);

        if (msg.value <= 25 ether) {
            donationType = DonationType.BRONZE;
            emit LogTokenMinted(msg.sender, tokenId, "bronze");
        } else if (msg.value <= 50 ether) {
            donationType = DonationType.SILVER;
            emit LogTokenMinted(msg.sender, tokenId, "silver");
        } else if (msg.value <= 100 ether) {
            donationType = DonationType.GOLD;
            emit LogTokenMinted(msg.sender, tokenId, "gold");
        } else if (msg.value <= 500 ether) {
            donationType = DonationType.DIAMOND;
            emit LogTokenMinted(msg.sender, tokenId, "diamond");
        } else {
            donationType = DonationType.PLATINUM;
            emit LogTokenMinted(msg.sender, tokenId, "platinum");
        }
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}
