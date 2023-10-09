// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


contract RPSContract{
    uint minBet = 0.001 ether;
    address public owner;


    constructor() payable {
        owner=msg.sender;
    }

    struct Game{
        string result;
        uint8 bet;
    }

    mapping (address => Game[]) results;

 
    function getHistory() public view returns(Game[] memory){
        return results[msg.sender];
    }

    function random() private view returns (uint amount) {
        amount = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.number))) % 3;
        amount = amount;
        return amount;
    }    

    function computerPlay() private view  returns(string memory){
        string[3] memory choices = ["rock", "paper", "scissors"];
        uint randomIndex = random();
        return choices[randomIndex];
    }

    modifier minimalBet(){
        require(msg.value > minBet, "Minimal bet is 0.001 bnb");
        _;
    }


    function play(string memory playerSelection, uint _bet) public payable minimalBet{
        string memory roundResult = "";
        string memory computerSelection = computerPlay();

        if (keccak256(abi.encodePacked(playerSelection)) == keccak256(abi.encodePacked(computerSelection))) {
            roundResult = "It's a tie!";
            withdrawToTie(payable(msg.sender), _bet);
        } else if (
            (keccak256(abi.encodePacked(playerSelection)) == keccak256(abi.encodePacked("rock")) && keccak256(abi.encodePacked(computerSelection)) == keccak256(abi.encodePacked("scissors"))) ||
            (keccak256(abi.encodePacked(playerSelection)) == keccak256(abi.encodePacked("paper")) && keccak256(abi.encodePacked(computerSelection)) == keccak256(abi.encodePacked("rock"))) ||
            (keccak256(abi.encodePacked(playerSelection)) == keccak256(abi.encodePacked("scissors")) && keccak256(abi.encodePacked(computerSelection)) == keccak256(abi.encodePacked("paper")))
        ) {
            roundResult = "You win this round!";
            withdrawToWinner(payable(msg.sender), _bet);
        } else {
            roundResult = "Computer wins this round!";
        }

        Game memory res;
        res.result = roundResult;
        res.bet = uint8(msg.value);

        results[msg.sender].push(res);
    }


    function withdrawToWinner(address payable  _to, uint bet) private  {
        _to.transfer(bet * 2);
    }

     function withdrawToTie(address payable  _to, uint bet) private  {
        _to.transfer(bet);
    }
}