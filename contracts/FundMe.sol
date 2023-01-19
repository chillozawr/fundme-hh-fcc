// Get funds from users
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// constant, immutable

error FundMe__NotOwner();

contract FundMe {
  using PriceConverter for uint256;

  uint256 public constant MINIMUS_USD = 50 * 1e18;

  address[] private s_funders;
  mapping(address => uint256) private s_addressToAmountFunded;

  address private immutable i_owner;

  AggregatorV3Interface private s_priceFeed;

  modifier onlyOwner() {
    // require(msg.sender == i_owner, "Sender is not owner");
    if (msg.sender != i_owner) {
      revert FundMe__NotOwner();
    }
    _;
  }

  constructor(address priceFeedAddress) {
    i_owner = msg.sender;
    s_priceFeed = AggregatorV3Interface(priceFeedAddress);
  }

  function fund() public payable {
    //want to be able to set a minimum fund amount in USD
    // 1. How do we send ETH to this contract?
    require(
      msg.value.getConversionRate(s_priceFeed) >= MINIMUS_USD,
      "You need to spend more ETH!"
    ); // 1e18 == 1 * 10 ** 18 == 10000000000 wei
    // 18 decimals

    // What is reverting
    // undo any action before, and send remaining gas back

    s_funders.push(msg.sender);
    s_addressToAmountFunded[msg.sender] += msg.value;
  }

  function withdraw() public onlyOwner {
    for (
      uint256 funderIndex = 0;
      funderIndex < s_funders.length;
      funderIndex++
    ) {
      address funder = s_funders[funderIndex];
      s_addressToAmountFunded[funder] = 0;
    }
    // reset the array
    s_funders = new address[](0);
    // actually withdraw the funds

    // TRANSFER method

    // msg.sender == address TYPE
    // payable(msg.sender) == payable address TYPE
    // payable(msg.sender).transfer(address(this).balance);

    // send
    // bool sendSuccess = payable(msg.sender).send(address(this).balance);
    // require(sendSuccess, "Send failed");

    // call
    (bool callSuccess, ) = payable(msg.sender).call{
      value: address(this).balance
    }("");
    require(callSuccess, "Call failed");
  }

  function cheaperWithdraw() public payable onlyOwner {
    address[] memory funders = s_funders;
    // mappings can't be in memory
    for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
      address funder = funders[funderIndex];
      s_addressToAmountFunded[funder] = 0;
    }
    s_funders = new address[](0);
    (bool callSuccess, ) = payable(msg.sender).call{
      value: address(this).balance
    }("");
    require(callSuccess, "Call failed");
  }

  function getOwner() public view returns (address) {
    return i_owner;
  }

  function getFunder(uint256 index) public view returns (address) {
    return s_funders[index];
  }

  function getAddressToAmountFunded(
    address funder
  ) public view returns (uint256) {
    return s_addressToAmountFunded[funder];
  }

  function getPriceFeed() public view returns (AggregatorV3Interface) {
    return s_priceFeed;
  }
}
