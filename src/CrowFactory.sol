// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./CrowCampaign.sol";

contract CrowFactory {
    address[] private deployedCampaigns;

    event CampaignCreated(
        address indexed campaignAddress,
        address indexed creator,
        uint256 timestamp
    );

    function createCampaign(
        string memory title,
        string memory description,
        uint goalAmount,
        uint deadline
    ) external returns (address) {        
        CrowCampaign newCampaign = new CrowCampaign(
            msg.sender,
            title,
            description,
            goalAmount,
            deadline
        );

        deployedCampaigns.push(address(newCampaign));
        emit CampaignCreated(address(newCampaign), msg.sender, block.timestamp);

        return address(newCampaign);
    }

    function getAllCampaigns() external view returns (address[] memory) {
        return deployedCampaigns;
    }
}
