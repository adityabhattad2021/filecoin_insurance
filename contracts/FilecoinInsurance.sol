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


    function isInsurancePaymentTime(address _issuee) internal view returns(bool) {
        uint256 timeOfLastPayment=insuranceIssuees[_issuee].timeOfLastPremiumPayment;
        uint256 currentTime=block.timestamp;
        uint256 timePassedSinceLastPayment=currentTime.sub(timeOfLastPayment);
        if(timePassedSinceLastPayment>=minDurationBetweenPayments && timePassedSinceLastPayment<=maxDurationBetweenPayments){
            return true;
        }
        else{
            return false;
        }
    }

    function hasPaidAllPreviousPremiums(address _issuee) internal view returns(bool) {
        uint timesPremiumPaid=insuranceIssuees[_issuee].timesPremiumPaid;
        uint256 insuranceStartTime=insuranceIssuees[_issuee].premiumStartTime;
        uint256 insuranceEndTime=insuranceIssuees[_issuee].premiumEndTime;  
        uint256 minimumDurationBetweenPayments=minDurationBetweenPayments;
        // Number of times premium should have been paid
        uint256 timesPremiumShouldHaveBeenPaid=insuranceEndTime.sub(insuranceStartTime).div(minimumDurationBetweenPayments);
        if(timesPremiumPaid==timesPremiumShouldHaveBeenPaid-1){
            return true;
        }
        else{
            return false;
        }
    }


    function isInsuranceValid(address _issuee) internal view returns(bool) {
        uint256 currentTime=block.timestamp;
        uint256 insuranceEndTime=insuranceIssuees[_issuee].premiumEndTime;
        if(currentTime<=insuranceEndTime){
            return true;
        }
        else{
            return false;
        }
    }

    function isRegisteredForInsurance(address _issuee) internal view returns(bool) {
        if(insuranceIssuees[_issuee].isInsured==true){
            return true;
        }
        else{
            return false;
        }
    }

    modifier validPremiumPayment(address _issuee) {
        require(isRegisteredForInsurance(_issuee), "Not registered");
        require(isInsurancePaymentTime(_issuee), "Premium payment time not reached");
        require(hasPaidAllPreviousPremiums(_issuee), "Previous premiums not paid");
        require(isInsuranceValid(_issuee), "Insurance expired");
        _;
    }

    function getPremium() public payable validPremiumPayment(msg.sender) {

        insuranceIssuees[msg.sender].timesPremiumPaid=insuranceIssuees[msg.sender].timesPremiumPaid.add(1);
        insuranceIssuees[msg.sender].timeOfLastPremiumPayment=block.timestamp;

        emit PremiumPaid(msg.value, msg.sender, block.timestamp);
    }


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
