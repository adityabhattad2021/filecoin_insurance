// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./mocks/InterfaceQueryAPI.sol";

interface IVerifier {
    function verifyMinerData() external returns (bool);
    function verifyMinorBenificiary() external returns (bool);
    function calculatePremium(string memory _minorAddress) external returns (uint256);
    function calculateClaimAmount(string memory _minorAddress) external returns (uint256);
    function isClaimValid(address _minorAddress) external returns (bool);
}


contract Verifier{

    using SafeMath for uint;

    address public queryAPIAddress;
    
    constructor(address _queryAPIAddress){
        queryAPIAddress = _queryAPIAddress;
    }

    /**
     * @notice Verifies the miner data
     * @return bool
     */
    function verifyMinerData() internal view returns (bool){
        IQueryAPI queryAPI = IQueryAPI(queryAPIAddress);
        IQueryAPI.minerInfo memory minerInfo = queryAPI.getMinerInfo("f002112");
        //   TODO : Add the logic to verify the miner data
        return true;
    }

    /**
     * @notice calculates the premium to be paid based on the miner data
     * @return bool
     */
    function calculatePremium(string memory _minorID) external view returns (uint256){
        uint basePremium = 100 ether;
        IQueryAPI queryAPI = IQueryAPI(queryAPIAddress);
        IQueryAPI.minerInfo memory minerInfo = queryAPI.getMinerInfo(_minorID);
        uint premium=basePremium.mul(minerInfo.sector_size).div(10**18);
        return premium;
    }

    /**
     * @notice calculates the claimAmount to be paid based on the miner data
     * @return bool
     */
    function calculateClaimAmount(string memory _minorID) external view returns (uint256){
        IQueryAPI queryAPI = IQueryAPI(queryAPIAddress);
        IQueryAPI.minerInfo memory minerInfo = queryAPI.getMinerInfo(_minorID);
        uint claimAmount= minerInfo.availableBalance.add(minerInfo.vestingFunds).add(minerInfo.initialPledge);
        return claimAmount;
    }

    /**
     * @notice Verifies the minor benificiary
     * @return bool
     */
    function verifyMinorBenificiary() internal view returns (bool){
        IQueryAPI queryAPI = IQueryAPI(queryAPIAddress);
        return queryAPI.confirmBenificiaryAddress();
    }

    function isClaimValid(address _minorAddress) external view returns (bool){
        // TODO : Add the logic to verify the claim
        bool isMinorBenificiary= verifyMinorBenificiary();
        bool isMinerDataValid = verifyMinerData();
        return isMinorBenificiary && isMinerDataValid;
    }



}