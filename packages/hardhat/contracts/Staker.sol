// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";
error Staker__NotOpenForWithdraw();
error Staker__TransferFailed();

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    event Stake(address indexed sender, uint256 amount);

    // change below variables to private and add the getters
    mapping(address => uint256) public s_balances;
    uint256 public constant threshold = 1 ether;
    uint256 public deadline = block.timestamp + 30 seconds;
    bool public openForWithdraw = false;

    function stake() public payable {
        s_balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    function execute() public {
        if (address(this).balance >= threshold && block.timestamp > deadline) {
            exampleExternalContract.complete{value: address(this).balance}();
        } else {
            openForWithdraw = true;
        }
    }

    function withdraw() public {
        if (!openForWithdraw) {
            revert Staker__NotOpenForWithdraw();
        }

        uint256 _amount = s_balances[msg.sender];
        s_balances[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        if (!success) {
            revert Staker__TransferFailed();
        }
    }

    function timeLeft() public view returns (uint256) {
        uint256 _timeLeft = 0;
        int256 _time = int256(deadline) - int256(block.timestamp);

        if (_time >= 0) {
            _timeLeft = uint256(_time);
        }

        return (_timeLeft);
    }

    receive() external payable {
        stake();
    }
}
