// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 文件名去掉空格和连字符，匹配实际文件名称
import "./day14_BaseDepositBox.sol";

contract TimeLockedDepositBox is BaseDepositBox {
    uint256 private unlockTime;

    // 父类 BaseDepositBox 有构造函数参数 _metadata，子类必须传递
    constructor(string memory _metadata, uint256 lockDuration) BaseDepositBox(_metadata) {
        unlockTime = block.timestamp + lockDuration;
    }

    // 时间解锁修饰器：确保只有解锁后才能执行函数
    modifier timeUnlocked() {
        require(block.timestamp >= unlockTime, "Box is still time-locked");
        _;
    }

    // 实现父类的抽象函数
    function getBoxType() external pure override returns (string memory) {
        return "TimeLocked";
    }

    // getSecret 函数：增加时间锁限制
    function getsecret() public view override onlyOwner timeUnlocked returns (string memory) {
        //父类 secret 是 internal，直接返回而非调用 super.getSecret()（父类未实现该函数）
        return secret;
    }

    // 获取解锁时间
    function getUnlockTime() external view returns (uint256) {
        return unlockTime;
    }

    // 获取剩余锁定时间
    function getRemainingLockTime() external view returns (uint256) {
        if (block.timestamp >= unlockTime) return 0;
        return unlockTime - block.timestamp;
    }

    // 补全接口要求的其他函数（避免 abstract 错误）
    function transferOwnership(address newOwner) external override onlyOwner {
        require(newOwner != address(0), "Invalid new owner");
        owner = newOwner;
    }

    function getDepositTime() external view override returns (uint256) {
        return depositTime;
    }
}

    
