//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IQueryAPI {
    struct minerInfo {
        string minorID;
        uint addressTotalBalance;
        uint initialPledge;
        uint lockedBlockRewards;
        uint activeSectors;
        uint faultySectors;
        uint recoveredSectors;
    }

    function confirmBenificiaryAddress() external pure returns (bool);

    function getMinerInfo(
        string memory minerAddress
    ) external view returns (minerInfo memory);

    function mockGenerateMinerInfo(address _minerAddress) external;
}
