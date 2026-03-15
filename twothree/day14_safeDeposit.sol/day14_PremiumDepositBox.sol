// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./day14_BaseDepositBox.sol";

contract PremiumDepositBox is BaseDepositBox {
    constructor(string memory _metadata) BaseDepositBox(_metadata) {}
    
    function getBoxType() external pure override returns (string memory) {
        return "Premium";
    }

    function transferOwnership(address newOwner) external override onlyOwner {
        require(newOwner != address(0), "Invalid new owner");
        owner = newOwner;
    }

    function getsecret() external view override onlyOwner returns (string memory) {
        return secret;
    }

    function getDepositTime() external view override returns (uint256) {
        return depositTime;
    }
}