// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Whitelist.sol";

/**
 * @title NFTMinter
 * @dev Example NFT contractt that uses the Whitelist contract
 */
contract NFTMinter is ERC721, Ownable {
    Whitelist public whitelist;
    uint256 public currentTokenId;
    uint256 public constant MAX_SUPPLY = 1000;

    mapping(address => bool) public hasMinted;

    event WhitelistContractUpdated(
        address indexed oldContract,
        address indexed newContract
    );
    constructor(
        string memory _name,
        string memory _symbol,
        address _whitelistContract
    ) ERC721(_name, _symbol) Ownable(msg.sender) {
        whitelist = Whitelist(_whitelistContract);
    }

    /**
     * @dev Updates the whitelist contract address (only owner)
     * @param _newWhitelistContract The new whitelist contract address
     */
    function updateWhitelistContract(
        address _newWhitelistContract
    ) external onlyOwner {
        address oldContract = address(whitelist);
        whitelist = Whitelist(_newWhitelistContract);

        emit WhitelistContractUpdated(oldContract, _newWhitelistContract);
    }

    /**
     * @dev Mint function restricted to whitelisted addresses
     * @param _merkleProof The Merkle proof for the caller's address
     */
    function whitelistMint(bytes32[] calldata _merkleProof) external {
        require(currentTokenId < MAX_SUPPLY, "Max supply reached");
        require(!hasMinted[msg.sender], "Already Minted");
        require(
            whitelist.isWhitelisted(msg.sender, _merkleProof),
            "Not whitelisted"
        );

        hasMinted[msg.sender] = true;
        currentTokenId++;

        _mint(msg.sender, currentTokenId);
    }

    /**
     * @dev Returns the total supply of tokens
     */
    function totalSupply() external view returns (uint256) {
        return currentTokenId;
    }
}
