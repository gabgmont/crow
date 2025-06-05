// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CrowFundingCampaign {
    address public creator;
    string public title;
    string public description;
    uint public goalAmount;
    uint public deadline;
    uint public totalCollected;
    bool public fundsWithdrawn;

    mapping(address => uint) public contributions;

    event ContributionMade(address indexed contributor, uint amount);
    event FundsWithdrawn(uint amount);
    event RefundIssued(address indexed contributor, uint amount);

    constructor(
        address _creator,
        string memory _title,
        string memory _description,
        uint _goalAmount,
        uint _deadline
    ) {
        require(_deadline > block.timestamp, "Deadline must be in the future");

        creator = _creator;
        title = _title;
        description = _description;
        goalAmount = _goalAmount;
        deadline = _deadline;
    }

    function contribute() external payable {
        require(block.timestamp < deadline, "Campaign has ended");
        require(msg.value > 0, "Must send ETH");

        contributions[msg.sender] += msg.value;
        totalCollected += msg.value;

        emit ContributionMade(msg.sender, msg.value);
    }

    function withdrawFunds() external {
        require(msg.sender == creator, "Only creator");
        require(block.timestamp >= deadline, "Campaign not ended yet");
        require(totalCollected >= goalAmount, "Goal not reached");
        require(!fundsWithdrawn, "Already withdrawn");

        fundsWithdrawn = true;
        payable(creator).transfer(address(this).balance);

        emit FundsWithdrawn(address(this).balance);
    }

    function requestRefund() external {
        require(block.timestamp >= deadline, "Campaign not ended");
        require(totalCollected < goalAmount, "Goal was met");
        uint amount = contributions[msg.sender];
        require(amount > 0, "Nothing to refund");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit RefundIssued(msg.sender, amount);
    }
}
