// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TournamentPrize {
    address public owner;
    uint256 public totalPrizePool;
    bool public prizeDistributed;

    mapping(address => uint256) public winnerShares;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Accept ETH to fund the prize pool
    receive() external payable {
        require(!prizeDistributed, "Prize already distributed");
        totalPrizePool += msg.value;
    }

    // Set winners and distribute prizes
    function distributePrizes(address[] calldata winners, uint256[] calldata percentages) external onlyOwner {
        require(!prizeDistributed, "Prizes already distributed");
        require(winners.length == percentages.length, "Input length mismatch");

        uint256 totalPercent;
        for (uint256 i = 0; i < percentages.length; i++) {
            totalPercent += percentages[i];
        }
        require(totalPercent == 100, "Total percentage must equal 100");

        for (uint256 i = 0; i < winners.length; i++) {
            uint256 prize = (totalPrizePool * percentages[i]) / 100;
            winnerShares[winners[i]] = prize;
            payable(winners[i]).transfer(prize);
        }

        prizeDistributed = true;
    }

    // View individual winner share
    function getWinnerShare(address winner) external view returns (uint256) {
        return winnerShares[winner];
    }
}
