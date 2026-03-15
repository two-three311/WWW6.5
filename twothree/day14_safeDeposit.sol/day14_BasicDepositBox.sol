// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_BaseDepositBox.sol";

contract BasicDepositBox is BaseDepositBox {
    // 定义构造函数，向母类传递 metadata 参数
    constructor(string memory _metadata) BaseDepositBox(_metadata) {}
    
    // 实现母类的抽象函数 getBoxType
    function getBoxType() external pure override returns (string memory) {
        return "Basic";
    }

    //实现接口要求的 transferOwnership 函数
    function transferOwnership(address newOwner) external override onlyOwner {
        require(newOwner != address(0), "BasicDepositBox: invalid new owner");
        owner = newOwner;
    }

    //实现接口要求的 getsecret 函数
    function getsecret() external view override onlyOwner returns (string memory) {
        return secret; // 母类中 secret 已改为 internal 可见性
    }

    //实现接口要求的 getDepositTime 函数
    function getDepositTime() external view override returns (uint256) {
        return depositTime; // 母类中 depositTime 是 public 变量，可直接访问
    }
}