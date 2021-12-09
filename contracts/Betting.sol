// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract Betting {
    enum BettingType {
        Tie,
        TeamAWin,
        TeamBWin
    }
    
    struct Bet {
        address bettor;
        uint matchId;
        BettingType bettingType;
        uint odd;
        uint amount;
        bool isPaidOut;
    }
    
    event NewBet(
        address bettor,
        uint matchId,
        BettingType bettingType,
        uint odd,
        uint amount,
        uint date
    );
    
    event NewPayout(
        address winner,
        uint matchId,
        BettingType bettingType,
        uint odd,
        uint amount,
        uint payout,
        uint date
    );
    
    address public owner;
    address public bettingAdmin;
    uint public deadlineTime;
    
    mapping(uint => mapping(uint => Bet[])) private allBets;

    constructor(uint bettingTimeInHours) {
        owner = msg.sender;
        bettingAdmin = msg.sender;
        deadlineTime = block.timestamp + bettingTimeInHours * 1 hours;
    }
    
    receive() external payable {}
    
    function sendMoneyToBettingPlatform() external payable {}
    
    function placeBet(
        uint matchId,
        uint bettingType,
        uint oddForWinning
    )
        external
        payable
    {
        require(block.timestamp <= deadlineTime, "You can only bet before deadline!");
        require(msg.value > 0, "Betting amount must be greater than zero!");
        require(uint(BettingType.TeamBWin) >= bettingType, "Invalid betting type!");
        Bet[] storage bets = allBets[matchId][bettingType];
        bets.push(
            Bet(
               msg.sender,
               matchId,
               BettingType(bettingType),
               oddForWinning,
               msg.value,
               false
            )
        );
        emit NewBet(
            msg.sender,
            matchId,
            BettingType(bettingType),
            oddForWinning,
            msg.value,
            block.timestamp
        );
    }
    
    function payWinnningBets(
        uint matchId,
        uint winningType
    ) 
        external
    {
        require(msg.sender == bettingAdmin, "Only for betting administrator!");
        require(block.timestamp > deadlineTime, "Payout only after deadline!");
        require(uint(BettingType.TeamBWin) >= winningType, "Invalid betting type!");
        Bet[] storage winningBets = allBets[matchId][winningType];
        for(uint iterator = 0; iterator < winningBets.length; iterator++) {
            if(winningBets[iterator].isPaidOut == false) {
                uint initialAmount = winningBets[iterator].amount;
                uint winningOdd = winningBets[iterator].odd;
                uint totalPayout = (initialAmount * 95 / 100) * winningOdd;
                require(address(this).balance >= totalPayout, "There is not enough money in platform for payout!");
                payable(winningBets[iterator].bettor).transfer(totalPayout);
                winningBets[iterator].isPaidOut = true;
                emit NewPayout(
                    winningBets[iterator].bettor,
                    matchId,
                    BettingType(winningType),
                    winningOdd,
                    initialAmount,
                    totalPayout,
                    block.timestamp
                );
            }
        }
    }
    
    function setBettingAdmin(address adr) external {
        require(msg.sender == owner, "Only for owner!");
        bettingAdmin = adr;
    }
    
    function getBalanceOfBettingPlatform() external view returns (uint) {
        return address(this).balance;
    }
}