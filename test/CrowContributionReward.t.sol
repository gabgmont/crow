// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console} from "forge-std/Test.sol";
import {CrowContributionReward} from "../src/CrowContributionReward.sol";

contract CrowContributionRewardTest is Test {
    CrowContributionReward reward;

    address public random;
    address public client;
    address public campaign;
    string public rewardName = 'Legendary Contributor';
    string public rewardSymbol = 'LGC';
    string public metadataURI = 'https://rewardmetadata.com';
    uint256 minDonation = 0.3 ether;

    function setUp() public {
        campaign = vm.addr(1);
        client = vm.addr(2);
        random = vm.addr(9);

        reward = new CrowContributionReward(
            campaign,
            rewardName,
            rewardSymbol,
            metadataURI,
            minDonation
        );
    }

    function test_Mint() public {
        vm.prank(campaign);

        reward.mint(client);

        assertTrue(reward.hasReceivedReward(client));
    }

    function test_MintNotOwner() public {
        vm.prank(random);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", random));

        reward.mint(client);

        assertTrue(!reward.hasReceivedReward(client));
        
    }
}
