// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ========== 1. 接口定义 ==========
interface IDepositBox {
    function getOwner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function storeSecret(string memory secret) external;
    function getsecret() external view returns (string memory);
    function getBoxType() external pure returns (string memory);
    function getDepositTime() external view returns (uint256);
}

// ========== 2. 抽象合约 ==========
abstract contract BaseDepositBox is IDepositBox {
    address public owner;
    string public metadata;
    string internal secret;
    uint256 public depositTime;

    constructor(string memory _metadata) {
        owner = msg.sender;
        metadata = _metadata;
        depositTime = block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function storeSecret(string memory _secret) external override onlyOwner {
        secret = _secret;
    }

    function getBoxType() external pure virtual override returns (string memory);
}

// ========== 3. 基础盒子合约 ==========
contract BasicDepositBox is BaseDepositBox {
    constructor(string memory _metadata) BaseDepositBox(_metadata) {}

    function getBoxType() external pure override returns (string memory) {
        return "Basic";
    }

    function transferOwnership(address newOwner) external override onlyOwner {
        require(newOwner != address(0), "Invalid owner");
        owner = newOwner;
    }

    function getsecret() external view override onlyOwner returns (string memory) {
        return secret;
    }

    function getDepositTime() external view override returns (uint256) {
        return depositTime;
    }
}

// ========== 4. 高级盒子合约 ==========
contract PremiumDepositBox is BaseDepositBox {
    constructor(string memory _metadata) BaseDepositBox(_metadata) {}

    function getBoxType() external pure override returns (string memory) {
        return "Premium";
    }

    function transferOwnership(address newOwner) external override onlyOwner {
        require(newOwner != address(0), "Invalid owner");
        owner = newOwner;
    }

    function getsecret() external view override onlyOwner returns (string memory) {
        return secret;
    }

    function getDepositTime() external view override returns (uint256) {
        return depositTime;
    }
}

// ========== 5. 时间锁盒子合约 ==========
contract TimeLockedDepositBox is BaseDepositBox {
    uint256 private unlockTime;

    constructor(string memory _metadata, uint256 lockDuration) BaseDepositBox(_metadata) {
        unlockTime = block.timestamp + lockDuration;
    }

    modifier timeUnlocked() {
        require(block.timestamp >= unlockTime, "Still locked");
        _;
    }

    function getBoxType() external pure override returns (string memory) {
        return "TimeLocked";
    }

    function getsecret() external view override onlyOwner timeUnlocked returns (string memory) {
        return secret;
    }

    function transferOwnership(address newOwner) external override onlyOwner {
        require(newOwner != address(0), "Invalid owner");
        owner = newOwner;
    }

    function getDepositTime() external view override returns (uint256) {
        return depositTime;
    }

    function getUnlockTime() external view returns (uint256) {
        return unlockTime;
    }
}

// ========== 6. 管理器合约（核心） ==========
contract VaultManager {
    mapping(address => address[]) private userDepositBoxes;
    mapping(address => string) private boxNames;

    event BoxCreated(address indexed owner, address indexed boxAddress, string boxType);
    event BoxNamed(address indexed boxAddress, string name);

    // 修复：创建BasicBox时传递metadata参数
    function createBasicBox() external returns (address) {
        BasicDepositBox box = new BasicDepositBox("Basic Deposit Box");
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Basic");
        return address(box);
    }

    // 修复：创建PremiumBox时传递metadata参数
    function createPremiumBox() external returns (address) {
        PremiumDepositBox box = new PremiumDepositBox("Premium Deposit Box");
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Premium");
        return address(box);
    }

    // 修复：创建TimeLockedBox时传递metadata + lockDuration参数
    function createTimeLockedBox(uint256 lockDuration) external returns (address) {
        TimeLockedDepositBox box = new TimeLockedDepositBox("TimeLocked Deposit Box", lockDuration);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "TimeLocked");
        return address(box);
    }

    function nameBox(address boxAddress, string calldata name) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        boxNames[boxAddress] = name;
        emit BoxNamed(boxAddress, name);
    }

    function storeSecret(address boxAddress, string calldata secret) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        box.storeSecret(secret);
    }

    function transferBoxOwnership(address boxAddress, address newOwner) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        box.transferOwnership(newOwner);

        address[] storage boxes = userDepositBoxes[msg.sender];
        for (uint i = 0; i < boxes.length; i++) {
            if (boxes[i] == boxAddress) {
                boxes[i] = boxes[boxes.length - 1];
                boxes.pop();
                break;
            }
        }

        userDepositBoxes[newOwner].push(boxAddress);
    }

    function getUserBoxes(address user) external view returns (address[] memory) {
        return userDepositBoxes[user];
    }

    function getBoxName(address boxAddress) external view returns (string memory) {
        return boxNames[boxAddress];
    }

    function getBoxInfo(address boxAddress) external view returns (
        string memory boxType,
        address owner,
        uint256 depositTime,
        string memory name
    ) {
        IDepositBox box = IDepositBox(boxAddress);
        return (
            box.getBoxType(),
            box.getOwner(),
            box.getDepositTime(),
            boxNames[boxAddress]
        );
    }
}