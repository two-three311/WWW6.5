// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDepositBox {
    function getOwner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function storeSecret(string memory secret) external;
    function getsecret() external view returns (string memory);
    function getBoxType() external pure returns (string memory);
    function getDepositTime() external view returns (uint256);
}