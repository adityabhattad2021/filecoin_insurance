// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;




contract QueryAPI{
    // Structure of data regarding the storage  provider.

    // Mocking the data for now
    mapping(address => minerInfo) public minerInfoMap;

    struct minerInfo{
        address minerAddress;
        uint addressTotalBalance;
        uint initialPledge;
        uint lockedBlockRewards;
        uint activeSectors;
        uint faultySectors;
        uint recoveredSectors;
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
     * @param _minerAddress address of the miner
     */
    function mockGenerateMinerInfo(address _minerAddress) external {
        minerInfoMap[_minerAddress].minerAddress = _minerAddress;
        minerInfoMap[_minerAddress].addressTotalBalance = 30091*(10**18);
        minerInfoMap[_minerAddress].initialPledge = 26521*(10**18);
        minerInfoMap[_minerAddress].lockedBlockRewards =  1908*(10**18);
        minerInfoMap[_minerAddress].activeSectors = 70220;
        minerInfoMap[_minerAddress].faultySectors = 0;
        minerInfoMap[_minerAddress].recoveredSectors = 0;
    }


    /**
     * @notice Gets the miner info
     * @param minerAddress address of the miner
     * @return minerInfo
     */
    function getMinerInfo(address minerAddress) external view returns (minerInfo memory){
        return minerInfoMap[minerAddress];
    }

}