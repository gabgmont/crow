// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {CrowFactory} from "../src/CrowFactory.sol";

contract CrowFactoryTest is Test {
    CrowFactory public crow;

    function setUp() public {
        crow = new CrowFactory();
    }

    function test_CreateCampaign() public {
        address campaignAddress = crow.createCampaign(
            "Get me rich",
            "Contribute with me so i can stop working",
            100 ether,
            1781094992
        );

        assertTrue(campaignAddress != address(0));
    }

    function test_GetAllCampaings() public {
        address campaignAddress = crow.createCampaign(
            "Get me rich",
            "Contribute with me so i can stop working",
            100 ether,
            1781094992
        );

        address[] memory campaigns = crow.getAllCampaigns();

        assertTrue(campaigns.length > 0);
        assertTrue(campaigns[0] == campaignAddress);
    }
}
