// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./mocks/InterfaceQueryAPI.sol";

interface IVerifier {
    function verifyMinerData() external returns (bool);
    function verifyMinorBenificiary() external returns (bool);
    function calculatePremium(address _minorAddress) external returns (uint256);
    function calculateClaimAmount(address _minorAddress) external returns (uint256);
}


contract Verifier{

    address public queryAPIAddress;
    
    constructor(address _queryAPIAddress){
        queryAPIAddress = _queryAPIAddress;
    }

    /**
     * @notice Verifies the miner data
     * @return bool
     */
    function verifyMinerData() external view returns (bool){
        IQueryAPI queryAPI = IQueryAPI(queryAPIAddress);
        IQueryAPI.minerInfo memory minerInfo = queryAPI.getMinerInfo(msg.sender);
        //   TODO : Add the logic to verify the miner data
        return true;
    }

    /**
     * @notice calculates the premium to be paid based on the miner data
     * @return bool
     */
    function calculatePremium(address _minorAddress) external view returns (uint256){
        // TODO : Add the logic to calculate the premium
        return 100;
    }

    /**
     * @notice calculates the claimAmount to be paid based on the miner data
     * @return bool
     */
    function calculateClaimAmount(address _minorAddress) external view returns (uint256){
        // TODO : Add the logic to calculate the claim amount
        return 100;
    }

    /**
     * @notice Verifies the minor benificiary
     * @return bool
     */
    function verifyMinorBenificiary() external view returns (bool){
        IQueryAPI queryAPI = IQueryAPI(queryAPIAddress);
        return queryAPI.confirmBenificiaryAddress();
    }
}