// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./CrowFundingCampaign.sol";

contract CrowFundingFactory {
    address[] public deployedCampaigns;

    event CampaignCreated(address indexed campaignAddress, address indexed creator);

    function createCampaign(string memory title, string memory description, uint goalAmount, uint deadline) external {
        CrowFundingCampaign newCampaign = new CrowFundingCampaign(
            msg.sender,
            title,
            description,
            goalAmount,
            deadline
        );
        
        deployedCampaigns.push(address(newCampaign));
        emit CampaignCreated(address(newCampaign), msg.sender);
    }

    function getAllCampaigns() external view returns (address[] memory) {
        return deployedCampaigns;
    }
}
