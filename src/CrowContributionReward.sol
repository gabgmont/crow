// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract CrowContributionReward is ERC721, Ownable {
    
    uint256 private _nextTokenId;
    bytes private _metadataURI;
    uint256 private _minDonation;

    mapping(address => bool) private _contributed;

    constructor(
        address campaign,
        string memory name,
        string memory symbol,
        string memory metadataURI,        
        uint minDonation
    ) Ownable(campaign) ERC721(name, symbol) {
        _minDonation = minDonation;
        _metadataURI = bytes(metadataURI);
    }

    function mint(address to) external onlyOwner {
        require(!_contributed[to], "Already received reward.");

        _nextTokenId++;
        _mint(to, _nextTokenId);
        _contributed[to] = true;
    }

    function tokenURI(uint256) public view override returns (string memory) {
        return string(_metadataURI);
    }

    function getMinDonation() external view returns(uint256) {
        return _minDonation;
    }

    function hasReceivedReward(address addr) external view returns (bool) {
        return _contributed[addr];
    }
}
