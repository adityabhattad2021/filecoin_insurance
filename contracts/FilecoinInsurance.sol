// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Verifier.sol";
import "hardhat/console.sol";


contract FilecoinInsurance is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    uint256 private coverageAmount;
    uint256 private periodicPremium;
    uint256 private insuranceDuration;
    uint256 private minDurationBetweenPayments;
    uint256 private maxDurationBetweenPayments;
    address private verifierAddress;

    struct insuranceIssuee {
        bool isInsured;
        address payeeAddress;
        uint256 timesPremiumPaid;
        uint256 premiumStartTime;
        uint256 premiumEndTime;
        uint256 timeOfLastPremiumPayment;
        // Amount of premium to be paid in dollars (in wei)
        uint256 regularPremiumAmount;
        uint256 claimAmount;
        bool claimPaid;
    }
    mapping(address => insuranceIssuee) public insuranceIssuees;

    // Events
    event ClaimRejected(
        uint256 indexed claimAmount,
        address indexed payeeAddress
    );

    event ClaimPaid(
        uint256 indexed claimAmount,
        address indexed payeeAddress,
        uint256 indexed timeOfClaim
    );

    event PremiumPaid(
        uint256 indexed paidAmount,
        address indexed payeeAddress,
        uint256 indexed timeOfPayment
    );

    event InsuranceVariablesAdjusted(
        uint256 indexed coverageAmount,
        uint256 indexed periodicPremium,
        uint256 indexed insuranceDuration,
        uint256 minDurationBetweenPayments,
        uint256 maxDurationBetweenPayments
    );

    event StorageProviderReistered(
        address indexed storageProvider,
        uint256 indexed periodicPremium,
        uint256 indexed claimAmount
    );

    /**
     * @notice Constructor for the contract
     * @dev Sets the coverage amount, periodic premium and insurance duration
     * @param _durationBetweenPayments Minimum duration between payments
     * @param _insuranceDuration Duration of the insurance
     * @param _verifierAddress Address of the verifier contract
     */
    constructor(
        uint256 _durationBetweenPayments,
        uint256 _insuranceDuration,
        address _verifierAddress
    ) {
        minDurationBetweenPayments = _durationBetweenPayments;
        maxDurationBetweenPayments = minDurationBetweenPayments.add(5 days);
        insuranceDuration = _insuranceDuration;
        verifierAddress = _verifierAddress;
    }

    /**
     * @notice Register a storage provider for insurance
     * @dev Only owner can register a storage provider
     * @param storageProvider Address of the storage provider
     * @param _periodicPremium Amount of premium to be paid
     * @param _claimAmount Amount of claim to be paid
     */
    function _registerStorageProvider(
        address storageProvider,
        uint256 _periodicPremium,
        uint256 _claimAmount
    ) internal {
        require(
            insuranceIssuees[storageProvider].isInsured == false,
            "Already registered"
        );

        insuranceIssuees[storageProvider].isInsured = true;
        insuranceIssuees[storageProvider].payeeAddress = storageProvider;

        insuranceIssuees[storageProvider].timesPremiumPaid = 0;
        insuranceIssuees[storageProvider].premiumStartTime = block.timestamp;

        insuranceIssuees[storageProvider].premiumEndTime = block.timestamp.add(
            insuranceDuration
        );

        insuranceIssuees[storageProvider]
            .regularPremiumAmount = _periodicPremium;

        insuranceIssuees[storageProvider].claimAmount = _claimAmount;

        insuranceIssuees[storageProvider].timeOfLastPremiumPayment = block
            .timestamp;

        insuranceIssuees[storageProvider].claimPaid = false;

        emit StorageProviderReistered(
            storageProvider,
            _periodicPremium,
            _claimAmount
        );
    }

    function registerStorageProvider(
        address _storageProvider,
        string memory _storageProviderID
    ) external onlyOwner {
        // TODO: get the premium and claim amount from the verifier
        uint256 _periodicPremium = IVerifier(verifierAddress).calculatePremium(
            _storageProviderID
        );
        uint256 _claimAmount = IVerifier(verifierAddress).calculateClaimAmount(
            _storageProviderID
        );
        
        _registerStorageProvider(
            _storageProvider,
            _periodicPremium,

            _claimAmount
        );
    }

    /**
     * @notice Check if the storage provider is eligible for insurance payment
     * @dev internal function
     * @param _issuee Address of the storage provider
     */
    function isInsurancePaymentTime(
        address _issuee
    ) internal view returns (bool) {
        uint256 timeOfLastPayment = insuranceIssuees[_issuee]
            .timeOfLastPremiumPayment;
        uint256 currentTime = block.timestamp;
        uint256 timePassedSinceLastPayment = currentTime.sub(timeOfLastPayment);

        if (
            timePassedSinceLastPayment >= minDurationBetweenPayments &&
            timePassedSinceLastPayment <= maxDurationBetweenPayments
        ) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @notice Check if the storage provider has paid all previous premiums
     * @dev internal function
     * @param _issuee Address of the storage provider
     * @return bool
     */
    function hasPaidAllPreviousPremiums(
        address _issuee
    ) internal view returns (bool) {
        uint timesPremiumPaid = insuranceIssuees[_issuee].timesPremiumPaid;
        uint256 insuranceStartTime = insuranceIssuees[_issuee].premiumStartTime;
        uint256 minimumDurationBetweenPayments = minDurationBetweenPayments;
        // Number of times premium should have been paid
        uint256 timesPremiumShouldHaveBeenPaid = block
            .timestamp
            .sub(insuranceStartTime)
            .div(minimumDurationBetweenPayments);

        if (timesPremiumPaid == timesPremiumShouldHaveBeenPaid - 1) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @notice Check if the storage provider's insurance is valid
     * @dev internal function
     * @param _issuee Address of the storage provider
     */
    function isInsuranceValid(address _issuee) internal view returns (bool) {
        uint256 currentTime = block.timestamp;
        uint256 insuranceEndTime = insuranceIssuees[_issuee].premiumEndTime;

        if (currentTime < insuranceEndTime) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @notice Check if the storage provider is registered for insurance
     * @dev internal function
     * @param _issuee Address of the storage provider
     */
    function isRegisteredForInsurance(
        address _issuee
    ) internal view returns (bool) {
        if (insuranceIssuees[_issuee].isInsured == true) {
            return true;
        } else {
            return false;
        }
    }

    function calculatePayablePremium(
        uint256 FILPrice,
        uint256 _reputationScore,
        address _SP
    ) public view returns (uint256) {
        uint256 reputationScore=_reputationScore.mul(10**18).div(100);
        uint256 premium = insuranceIssuees[_SP].regularPremiumAmount;
        uint256 payablePremium = premium.mul(10 ** 18).div(FILPrice).div(reputationScore).mul(10**18);
        return payablePremium;
    }

    /**
     * @notice Check if the premium payment is valid
     * @dev modifier
     * @param _issuee Address of the storage provider
     */
    modifier validPremiumPayment(address _issuee) {

        require(isRegisteredForInsurance(_issuee), "Not registered");
        require(isInsuranceValid(_issuee), "Insurance expired");
        require(
            isInsurancePaymentTime(_issuee),
            "Premium payment time not reached"
        );
        require(insuranceIssuees[_issuee].claimPaid == false, "Claim already paid");
        require(
            hasPaidAllPreviousPremiums(_issuee),
            "Previous premiums not paid"
        );
        _;
    }

    modifier requestForClaimValid(address _issuee) {
        require(isRegisteredForInsurance(_issuee), "Not registered");
        require(isInsuranceValid(_issuee), "Insurance expired");
        require(
            insuranceIssuees[_issuee].claimPaid == false,
            "Claim already paid"
        );
        uint256 timePassed=block.timestamp.sub(insuranceIssuees[_issuee].premiumStartTime);
        uint256 totolTime=insuranceIssuees[_issuee].premiumEndTime.sub(insuranceIssuees[_issuee].premiumStartTime);
        require(
            timePassed>=totolTime.mul(2).div(3),
            "Minimun duration to claim insurance not reached"
        );
        _;
    }

    /**
     * @notice Pay premium
     * @dev Only valid storage provider can pay premium
     * @param FILPrice Current FIL price
     */
    function getPremium(
        uint256 FILPrice,
        uint256 reputationScore
    ) public payable validPremiumPayment(msg.sender) {

        uint256 payablePremium = calculatePayablePremium(FILPrice,reputationScore,msg.sender);
        require(msg.value == payablePremium, "Incorrect premium amount");

        insuranceIssuees[msg.sender].timesPremiumPaid = insuranceIssuees[
            msg.sender
        ].timesPremiumPaid.add(1);
        insuranceIssuees[msg.sender].timeOfLastPremiumPayment = block.timestamp;

        emit PremiumPaid(msg.value, msg.sender, block.timestamp);
    }



    function raiseClaimRequest() public nonReentrant requestForClaimValid(msg.sender) {

        bool isClaimValid = IVerifier(verifierAddress).isClaimValid(msg.sender);

        if (isClaimValid) {
            insuranceIssuees[msg.sender].claimPaid = true;

            (bool success, ) = payable(msg.sender).call{value: insuranceIssuees[msg.sender].claimAmount}("");
            require(success, "Transfer failed.");

            emit ClaimPaid(
                insuranceIssuees[msg.sender].claimAmount,
                msg.sender,
                block.timestamp
            );

        } else {
            emit ClaimRejected(
                insuranceIssuees[msg.sender].claimAmount,
                msg.sender
            );
        }
    }

    // getter functions
    function getDurationBetweenPayments() public view returns (uint256) {
        return minDurationBetweenPayments;
    }

    function getInsuranceDuration() public view returns (uint256) {
        return insuranceDuration;
    }

    function getRegisteredStorageProvider(
        address _storageProvider
    ) public view returns (insuranceIssuee memory) {
        return insuranceIssuees[_storageProvider];
    }


    function getClaimAmount(address _storageProvider)
        public
        view
        returns (uint256)
    {
        return insuranceIssuees[_storageProvider].claimAmount;
    }

}
