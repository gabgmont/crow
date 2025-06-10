// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./CrowContributionReward.sol";

contract CrowCampaign is Ownable, ReentrancyGuard, Pausable {
    struct CampaignInfo {
        string title;
        string description;
        uint256 goalAmount;
        uint256 deadline;
        bool fundsWithdrawn;
        address[] rewards;
        address[] contributors;
    }

    string private _title;
    string private _description;
    uint256 private _goalAmount;
    uint256 private _deadline;
    bool private _fundsWithdrawn;
    address[] private _rewards;
    address[] private _contributors;

    mapping(address => uint) private _contributions;

    event ContributionMade(address indexed contributor, uint amount);
    event FundsWithdrawn(address indexed owner, uint amount);
    event RewardCreated(address indexed owner, uint minDonation);
    event RewardReceived(address indexed contributor, address indexed reward);
    event RewardNotReceived(address indexed contributor);

    constructor(
        address creator,
        string memory title,
        string memory description,
        uint256 goalAmount,
        uint256 deadline
    ) Ownable(creator) {
        require(deadline > block.timestamp, "Deadline must be in the future");

        _title = title;
        _description = description;
        _goalAmount = goalAmount;
        _deadline = deadline;
    }

    function contribute() external payable nonReentrant whenNotPaused {
        require(block.timestamp < _deadline, "Campaign has ended");
        require(msg.value > 0, "Must send ETH");

        _contributions[msg.sender] += msg.value;
        _contributors.push(msg.sender);

        emit ContributionMade(msg.sender, msg.value);
        
        bool receivedReward;

        for (uint32 i = 0; i < _rewards.length; i++) {
            CrowContributionReward rewardContract = CrowContributionReward(_rewards[i]);

            if (msg.value >= rewardContract.getMinDonation()) {
                rewardContract.mint(msg.sender);
                emit RewardReceived(msg.sender, _rewards[i]);
                receivedReward = true;
                
            } 
        }

        if (!receivedReward) {
            emit RewardNotReceived(msg.sender);
        }
    }

    function withdrawFunds() external nonReentrant onlyOwner {
        require(block.timestamp >= _deadline, "Campaign not ended yet");
        require(address(this).balance >= _goalAmount, "Goal not reached");
        require(!_fundsWithdrawn, "Already withdrawn");
        _fundsWithdrawn = true;

        payable(owner()).transfer(address(this).balance);

        emit FundsWithdrawn(owner(), address(this).balance);
    }

    function addReward(string memory name, string memory symbol, string memory metadataURI, uint minDonation) external onlyOwner returns (address) {
        CrowContributionReward reward = new CrowContributionReward(
            address(this),
            name,
            symbol,
            metadataURI,
            minDonation
        );
        
        _rewards.push(address(reward));

        emit RewardCreated(owner(), minDonation);

        return address(reward);
    }
    
    // Read functions
    
    function getCreatedBy() external view returns (address) {
        return owner();
    }

    function getTotalRaised() external view returns (uint256) {
        return address(this).balance;
    }

    function getContributedAmount(address addr) external view returns (uint256) {
        return _contributions[addr];
    }

    function getRaiseGoal() external view returns (uint256) {
        return _goalAmount;
    }

    function getTotalBackers() external view returns (uint256) {
        return _contributors.length;
    }

    function getCampaignRewards() external view returns (address[] memory) {
        return _rewards;
    }

    function getCampaignInfo() external view returns (CampaignInfo memory) {
        return CampaignInfo({
            title: _title,
            description: _description,
            goalAmount: _goalAmount,
            deadline: _deadline,
            fundsWithdrawn: _fundsWithdrawn,
            rewards: _rewards,
            contributors: _contributors
        });
    }
}
