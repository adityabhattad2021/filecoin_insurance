// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


// This mock QueryAPI is inspired by MinerAPI by Zondax AG.
contract QueryAPI{
    // Structure of data regarding the storage  provider.

    // Mocking the data for now
    mapping(string => minerInfo) public minerInfoMap;

    struct minerInfo{
        string minerId;
        uint availableBalance;
        uint initialPledge;
        uint vestingFunds;
        uint64 sector_size;
    }

    /**
     * @notice Verifies the minor benificiary
     * @return bool
     */
    function confirmBenificiaryAddress() external pure returns (bool){
        // this are hard coded values for testing purposes
        return true;
    }


    /**
     * @notice Mocks the miner info
     * @param _minorId address of the miner
     */
    function mockGenerateMinerInfo(string memory _minorId) external {
        minerInfoMap[_minorId].minerId = _minorId;
        minerInfoMap[_minorId].availableBalance=1000;
        minerInfoMap[_minorId].initialPledge = 50;
        minerInfoMap[_minorId].vestingFunds =  35;
        minerInfoMap[_minorId].sector_size=10;
    }


    /**
     * @notice Gets the miner info
     * @param minerID address of the miner
     * @return minerInfo
     */
    function getMinerInfo(string memory minerID) external view returns (minerInfo memory){
        return minerInfoMap[minerID];
    }

}