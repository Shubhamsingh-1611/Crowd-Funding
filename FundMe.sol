// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
// oracal chain data feed
//  import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
 import {PriceConverter} from "./PriceConverter.sol";
 
 error NotOwner();
 contract FundMe {

   using PriceConverter for uint256; // all the function of the library get associated with the uint256


   uint256 public minimumUsd = 5e18;
   address[] public funders;//to track the user funded this system


   address public owner;
   mapping(address funder => uint256 amountFunded) public  addressToAmountFunded;
    
    function fund() public payable  {
    //    Allow user to send fund
    // have a minimun sent
    // How to sent ETH to this contract
    require(msg.value.getConversionRate()>minimumUsd,"Didint sent enough fund");
    funders.push(msg.sender); //msg.sender is the person who send money
    addressToAmountFunded[msg.sender] += msg.value;
    }
    function withdraw() public  onlyOwner {

      // setting requie so that owner can only withdraw money
     
      // reset mapping
      for(uint256 i=0;i<funders.length;i++) {
         address funder = funders[i];
         addressToAmountFunded[funder] = 0;

      }
      // reset array
      funders = new address[](0);

      (bool calsucess,) = payable(msg.sender).call{value:address(this).balance}("");
      require(calsucess,"call Failed");
    }

    constructor() {
    owner = msg.sender;
    }
    
    receive() external payable {
      fund();
     }

     fallback() external payable {
      fund();
      }

   //  function getPrice() public view returns(uint256) {
   //   AggregatorV3Interface priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
   //  (,int256 price ,,,)= priceFeed.latestRoundData(); //this latestRound fuction return various data along with price so we have put comma
   //   return uint256(price*1e10);
   //  }

   //  function getConversionRate(uint256 ethAmount) public view returns(uint256) {
   //    uint256 ethPrice = getPrice();
   //    uint256 ethAmountInUsd = (ethPrice*ethAmount)/1e18;
   //    return ethAmountInUsd;
   //  }
   modifier onlyOwner() {
    require(msg.sender==owner,"Invalid user to withdraw");
    // if(msg.sender != owner) 
    _;
   }
 }