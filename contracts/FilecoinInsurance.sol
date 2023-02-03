// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract FilecoinInsurance is Ownable {    

    using SafeMath for uint256;
    uint256 private coverageAmount;
    uint256 private periodicPremium;
    uint256 private insuranceDuration;
    uint256 private minDurationBetweenPayments;
    uint256 private maxDurationBetweenPayments;

    struct insuranceIssuee{
        bool isInsured;
        address payeeAddress;
        uint256 timesPremiumPaid;
        uint256 premiumStartTime;
        uint256 premiumEndTime;
        uint256 timeOfLastPremiumPayment;
        uint256 timeOfClaim;
        uint256 claimAmount;
        bool claimPaid;
    }
    mapping(address => insuranceIssuee) public insuranceIssuees;

    // Events
    event PremiumPaid(
        uint256 indexed paidAmount,
        address indexed payeeAddress,
        uint256 indexed timeOfPayment
    );

    event insuranceVariablesAdjusted(
        uint256 indexed coverageAmount,
        uint256 indexed periodicPremium,
        uint256 indexed insuranceDuration,
        uint256  minDurationBetweenPayments,
        uint256  maxDurationBetweenPayments
    );

    constructor(
       uint256 _coverageAmount,
       uint256 _periodicPremium,
       uint256 _durationBetweenPayments,
       uint256 _insuranceDuration
    ){
        coverageAmount=_coverageAmount;
        periodicPremium=_periodicPremium;
        minDurationBetweenPayments=_durationBetweenPayments;
        maxDurationBetweenPayments=minDurationBetweenPayments.add(5 days);
        insuranceDuration=_insuranceDuration;
    }

    function registerStorageProvider(address storageProvider) public onlyOwner {
        require(insuranceIssuees[msg.sender].isInsured==false, "Already registered");
        insuranceIssuees[msg.sender].isInsured=true;
        insuranceIssuees[msg.sender].payeeAddress=storageProvider;
        insuranceIssuees[msg.sender].timesPremiumPaid=0;
        insuranceIssuees[msg.sender].premiumStartTime=block.timestamp;
        insuranceIssuees[msg.sender].premiumEndTime=block.timestamp.add(insuranceDuration);
        insuranceIssuees[msg.sender].timeOfLastPremiumPayment=block.timestamp;
        insuranceIssuees[msg.sender].timeOfClaim=0;
        insuranceIssuees[msg.sender].claimAmount=0;
        insuranceIssuees[msg.sender].claimPaid=false;
    }

    function getPremium() public payable {

        require(insuranceIssuees[msg.sender].isInsured, "Not registered");

        // Check for the latest premium value.
        require(msg.value==periodicPremium, "Incorrect premium amount");
        require(block.timestamp.sub(insuranceIssuees[msg.sender].timeOfLastPremiumPayment)>=minDurationBetweenPayments, "Premium paid too soon");
        require(block.timestamp.sub(insuranceIssuees[msg.sender].timeOfLastPremiumPayment)<=maxDurationBetweenPayments, "Premium paid too late");
        require(block.timestamp<=insuranceIssuees[msg.sender].premiumEndTime, "Insurance expired");

        uint256 timesPremiumPaidToVerify=insuranceIssuees[msg.sender].timesPremiumPaid;
        uint256 insuranceStartTime=insuranceIssuees[msg.sender].premiumStartTime;
        uint256 insuranceEndTime=insuranceIssuees[msg.sender].premiumEndTime;
        uint256 minimumDurationBetweenPayments=minDurationBetweenPayments;
        // Number of times premium should have been paid
        uint256 timesPremiumShouldHaveBeenPaid=insuranceEndTime.sub(insuranceStartTime).div(minimumDurationBetweenPayments);
        require(timesPremiumPaidToVerify==timesPremiumShouldHaveBeenPaid, "Any or some premiums were missed");

        insuranceIssuees[msg.sender].timesPremiumPaid=insuranceIssuees[msg.sender].timesPremiumPaid.add(1);
        insuranceIssuees[msg.sender].timeOfLastPremiumPayment=block.timestamp;

        emit PremiumPaid(msg.value, msg.sender, block.timestamp);
    }


    // TODO: Check the time for insurance payment.

    // TODO: check if isuee is eligible to pay the premium.

    // TODO: Number of premiums are not over paid as well as not under paid.


    function adjustInsuranceVariablesForFILPrice(
        uint256 _coverageAmount,
        uint256 _periodicPremium
    ) public onlyOwner {

        coverageAmount=_coverageAmount;
        periodicPremium=_periodicPremium;

        emit insuranceVariablesAdjusted(coverageAmount, periodicPremium, insuranceDuration, minDurationBetweenPayments, maxDurationBetweenPayments);
    }

    function adjustInsuranceVariablesForDuration(
        uint256 _minDurationBetweenPayments,
        uint256 _maxDurationBetweenPayments,
        uint256 _insuranceDuration
    ) public onlyOwner {

        minDurationBetweenPayments=_minDurationBetweenPayments;
        maxDurationBetweenPayments=_maxDurationBetweenPayments;
        insuranceDuration=_insuranceDuration;

        emit insuranceVariablesAdjusted(coverageAmount, periodicPremium, insuranceDuration, minDurationBetweenPayments, maxDurationBetweenPayments);
    }
}
