//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IQueryAPI {
    struct minerInfo{
        string minerId;
        uint availableBalance;
        uint initialPledge;
        uint vestingFunds;
        uint64 sector_size;
    }
    function confirmBenificiaryAddress() external pure returns (bool);

    function getMinerInfo(
        string memory minerAddress
    ) external view returns (minerInfo memory);

    function mockGenerateMinerInfo(address _minerAddress) external;
}
