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
        uint256 regularPremiumAmount;
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
       uint256 _durationBetweenPayments,
       uint256 _insuranceDuration
    ){
        minDurationBetweenPayments=_durationBetweenPayments;
        maxDurationBetweenPayments=minDurationBetweenPayments.add(5 days);
        insuranceDuration=_insuranceDuration;
    }

/**
 * @notice Register a storage provider for insurance
 * @dev Only owner can register a storage provider
 * @param storageProvider Address of the storage provider
 * @param _periodicPremium Amount of premium to be paid
 * @param _claimAmount Amount of claim to be paid
 */
    function registerStorageProvider(
        address storageProvider,
        uint256 _periodicPremium,
        uint256 _claimAmount
    ) public onlyOwner {
        require(insuranceIssuees[storageProvider].isInsured==false, "Already registered");
        insuranceIssuees[storageProvider].isInsured=true;
        insuranceIssuees[storageProvider].payeeAddress=storageProvider;
        insuranceIssuees[storageProvider].timesPremiumPaid=0;
        insuranceIssuees[storageProvider].premiumStartTime=block.timestamp;
        insuranceIssuees[storageProvider].premiumEndTime=block.timestamp.add(insuranceDuration);
        insuranceIssuees[storageProvider].regularPremiumAmount=_periodicPremium;
        insuranceIssuees[storageProvider].claimAmount=_claimAmount;
        insuranceIssuees[storageProvider].timeOfLastPremiumPayment=block.timestamp;
        insuranceIssuees[storageProvider].timeOfClaim=0;
        insuranceIssuees[storageProvider].claimAmount=0;
        insuranceIssuees[storageProvider].claimPaid=false;
    }

/**
 * @notice Check if the storage provider is eligible for insurance payment
 * @dev internal function
 * @param _issuee Address of the storage provider
 */
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

    /**
     * @notice Check if the storage provider has paid all previous premiums
     * @dev internal function
     * @param _issuee Address of the storage provider
     * @return bool
     */
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

    /**
     * @notice Check if the storage provider's insurance is valid
     * @dev internal function
     * @param _issuee Address of the storage provider
     */
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

    /**
     * @notice Check if the storage provider is registered for insurance
     * @dev internal function
     * @param _issuee Address of the storage provider
     */
    function isRegisteredForInsurance(address _issuee) internal view returns(bool) {
        if(insuranceIssuees[_issuee].isInsured==true){
            return true;
        }
        else{
            return false;
        }
    }

    /**
     * @notice Check if the premium payment is valid
     * @dev modifier
     * @param _issuee Address of the storage provider
     */
    modifier validPremiumPayment(address _issuee) {
        require(isRegisteredForInsurance(_issuee), "Not registered");
        require(isInsuranceValid(_issuee), "Insurance expired");
        require(isInsurancePaymentTime(_issuee), "Premium payment time not reached");
        require(hasPaidAllPreviousPremiums(_issuee), "Previous premiums not paid");
        _;
    }

    /**
     * @notice Pay premium
     * @dev Only valid storage provider can pay premium
     */
    function getPremium() public payable validPremiumPayment(msg.sender) {
        require(msg.value==insuranceIssuees[msg.sender].regularPremiumAmount, "Incorrect premium amount");

        insuranceIssuees[msg.sender].timesPremiumPaid=insuranceIssuees[msg.sender].timesPremiumPaid.add(1);
        insuranceIssuees[msg.sender].timeOfLastPremiumPayment=block.timestamp;

        emit PremiumPaid(msg.value, msg.sender, block.timestamp);
    }

    // getter functions
    function getDurationBetweenPayments() public view returns(uint256) {
        return minDurationBetweenPayments;
    }

    function getInsuranceDuration() public view returns(uint256) {
        return insuranceDuration;
    }
    

}
