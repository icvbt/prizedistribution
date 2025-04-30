// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TournamentPrize {
    address public owner;
    uint256 public totalPrizePool;
    bool public prizeDistributed;

    mapping(address => uint256) public winnerShares;
    address[] public winners;

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
    function distributePrizes(address[] calldata _winners, uint256[] calldata percentages) external onlyOwner {
        require(!prizeDistributed, "Prizes already distributed");
        require(_winners.length == percentages.length, "Input length mismatch");

        uint256 totalPercent;
        for (uint256 i = 0; i < percentages.length; i++) {
            totalPercent += percentages[i];
        }
        require(totalPercent == 100, "Total percentage must equal 100");

        for (uint256 i = 0; i < _winners.length; i++) {
            uint256 prize = (totalPrizePool * percentages[i]) / 100;
            winnerShares[_winners[i]] = prize;
            payable(_winners[i]).transfer(prize);
            winners.push(_winners[i]);
        }

        prizeDistributed = true;
    }

    // View individual winner share
    function getWinnerShare(address winner) external view returns (uint256) {
        return winnerShares[winner];
    }

    // NEW: Withdraw unclaimed or leftover funds
    function withdrawUnclaimedFunds() external onlyOwner {
        require(prizeDistributed, "Distribute prizes first");
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No funds to withdraw");
        payable(owner).transfer(contractBalance);
    }

    // NEW: Reset the contract for next tournament
    function resetTournament() external onlyOwner {
        require(prizeDistributed, "Previous tournament not finished");

        for (uint256 i = 0; i < winners.length; i++) {
            delete winnerShares[winners[i]];
        }
        delete winners;
        totalPrizePool = 0;
        prizeDistributed = false;
    }
}
