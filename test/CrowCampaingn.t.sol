// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {CrowCampaign} from "../src/CrowCampaign.sol";
import {CrowContributionReward} from "../src/CrowContributionReward.sol";

contract CrowCampaignTest is Test {
    CrowCampaign public campaign;

    address public creator;
    address public contributor;
    address public random;

    // Campaign
    string public campaignTitle = "Crow funding campaign";
    string public campaignDescription = "Campaign destined to raise funds for the gratest crowd funding platform.";
    uint256 public campaignGoalAmount = 100 ether;
    uint256 public campaignDeadline = 1893456000;

    // Reward
    string public rewardName = "Reward";
    string public rewardSymbol = "RWD";
    string public rewardMetadataURI = "https://rewardUri.com/image";
    uint rewardMinDonation = 0.5 ether;

    event ContributionMade(address indexed contributor, uint amount);
    event FundsWithdrawn(address indexed owner, uint amount);
    event RewardCreated(address indexed owner, uint minDonation);
    event RewardReceived(address indexed contributor, address indexed reward);
    event RewardNotReceived(address indexed contributor);

    function setUp() public {
        creator = vm.addr(1);
        contributor = vm.addr(2);
        random = vm.addr(3);

        deal(contributor, 10 ether);

        campaign = new CrowCampaign(
            creator,
            campaignTitle,
            campaignDescription,
            campaignGoalAmount,
            campaignDeadline
        );
    }

    function test_CreatedBy() public view {
        address _creator = campaign.getCreatedBy();

        assertTrue(_creator == creator);
    }

    function test_RaiseGoal() public view {
        uint256 _goalAmount = campaign.getRaiseGoal();

        assertTrue(_goalAmount == campaignGoalAmount);
    }

    function test_CampaignInfo() public view {
        CrowCampaign.CampaignInfo memory campaignInfo = campaign.getCampaignInfo();

        assertEq(campaignInfo.title, campaignTitle);
        assertEq(campaignInfo.description, campaignDescription);
        assertEq(campaignInfo.goalAmount, campaignGoalAmount);
        assertEq(campaignInfo.deadline, campaignDeadline);
        assertEq(campaignInfo.fundsWithdrawn, false);
        assertEq(campaignInfo.rewards.length, 0);
        assertEq(campaignInfo.contributors.length, 0);

    }

    function test_AddReward() public {
        address[] memory rewards = campaign.getCampaignRewards();
        assertEq(rewards.length, 0);
        
        vm.prank(creator);
        vm.expectEmit(true, true, true, true);
        emit RewardCreated(creator, rewardMinDonation);

        address rewardAddress = campaign.addReward(
            rewardName,
            rewardSymbol,
            rewardMetadataURI,
            rewardMinDonation
        );

        assertTrue(rewardAddress != address(0));

        rewards = campaign.getCampaignRewards();

        assertEq(rewards.length, 1);
        assertEq(rewards[0], rewardAddress);
    }

    function test_AddRewardNotCreator() public {
        vm.prank(random);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", random));

        campaign.addReward(
            rewardName,
            rewardSymbol,
            rewardMetadataURI,
            rewardMinDonation
        );

    }

    function test_Contribute() public {
        assertEq(contributor.balance, 10 ether);

        uint256 backers = campaign.getTotalBackers();
        assertEq(backers, 0);

        uint256 contributedAmount = campaign.getContributedAmount(contributor);
        assertEq(contributedAmount, 0);

        vm.prank(contributor);
        vm.expectEmit(true, true, true, true);
        emit ContributionMade(contributor, 1 ether);
        
        campaign.contribute{value: 1 ether}();
        
        assertEq(contributor.balance, 9 ether);
        assertEq(address(campaign).balance, 1 ether);

        backers = campaign.getTotalBackers();
        assertEq(backers, 1);

        contributedAmount = campaign.getContributedAmount(contributor);
        assertEq(contributedAmount, 1 ether);

    }

    
    function test_ContributeSameUser() public {
        assertEq(contributor.balance, 10 ether);

        uint256 backers = campaign.getTotalBackers();
        assertEq(backers, 0);

        uint256 contributedAmount = campaign.getContributedAmount(contributor);
        assertEq(contributedAmount, 0);

        vm.startPrank(contributor);
        vm.expectEmit(true, true, true, true);
        emit ContributionMade(contributor, 1 ether);
        
        campaign.contribute{value: 1 ether}();
        campaign.contribute{value: 2 ether}();
        
        vm.stopPrank();

        assertEq(contributor.balance, 7 ether);
        assertEq(address(campaign).balance, 3 ether);

        backers = campaign.getTotalBackers();
        assertEq(backers, 1);

        contributedAmount = campaign.getContributedAmount(contributor);
        assertEq(contributedAmount, 3 ether);

    }

    function test_ContributeGetReward() public {
        assertEq(contributor.balance, 10 ether);

        vm.prank(creator);
        address rewardAddress = campaign.addReward(
            rewardName,
            rewardSymbol,
            rewardMetadataURI,
            rewardMinDonation
        );

        assertTrue(rewardAddress != address(0));

        vm.expectEmit(true, true, true, true);
        emit RewardReceived(contributor, rewardAddress);

        vm.prank(contributor);
        campaign.contribute{value: 1 ether}();       
        
        assertEq(contributor.balance, 9 ether);
        assertEq(address(campaign).balance, 1 ether);

        CrowContributionReward reward = CrowContributionReward(rewardAddress);

        bool hasReceivedReward = reward.hasReceivedReward(contributor);
        assertTrue(hasReceivedReward);
    }

    function test_ContributeGetMultipleReward() public {
        assertEq(contributor.balance, 10 ether);

        vm.startPrank(creator);
        address reward1Address = campaign.addReward(
            rewardName,
            rewardSymbol,
            rewardMetadataURI,
            0.5 ether
        );

        address reward2Address = campaign.addReward(
            rewardName,
            rewardSymbol,
            rewardMetadataURI,
            1 ether
        );

        vm.stopPrank();

        assertTrue(reward1Address != address(0));

        vm.expectEmit(true, true, true, true);
        emit RewardReceived(contributor, reward1Address);

        vm.expectEmit(true, true, true, true);
        emit RewardReceived(contributor, reward2Address);

        vm.prank(contributor);
        campaign.contribute{value: 1 ether}();       
        
        assertEq(contributor.balance, 9 ether);
        assertEq(address(campaign).balance, 1 ether);

        CrowContributionReward reward1 = CrowContributionReward(reward1Address);

        bool hasReceivedReward1 = reward1.hasReceivedReward(contributor);
        assertTrue(hasReceivedReward1);

        CrowContributionReward reward2 = CrowContributionReward(reward2Address);

        bool hasReceivedReward2 = reward2.hasReceivedReward(contributor);
        assertTrue(hasReceivedReward2);
    }

    function test_ContributeMissReward() public {
        assertEq(contributor.balance, 10 ether);

        vm.prank(creator);
        address rewardAddress = campaign.addReward(
            rewardName,
            rewardSymbol,
            rewardMetadataURI,
            rewardMinDonation
        );

        assertTrue(rewardAddress != address(0));

        vm.expectEmit(true, true, true, true);
        emit RewardNotReceived(contributor);

        vm.prank(contributor);
        campaign.contribute{value: 0.3 ether}();       
        
        assertEq(contributor.balance, 9.7 ether);
        assertEq(address(campaign).balance, 0.3 ether);

    }
}