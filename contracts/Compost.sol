// SPDX-License-Identifier: MIT
// Degen Farm. Collectible NFT game
pragma solidity ^0.7.4;

import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/token/ERC20/IERC20.sol";
import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/token/ERC20/SafeERC20.sol";
import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/access/Ownable.sol";
import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/math/SafeMath.sol";
import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/math/Math.sol";

interface IDung is IERC20 {
    function mint(
        address to, 
        uint256 amount 
        ) external;
}
/**
 * @dev this contract forked from
 * https://github.com/Synthetixio/Unipool/blob/master/contracts/Unipool.sol
 * 
*/
contract Compost is Ownable {
	using SafeMath  for uint256;
	using SafeERC20 for IERC20;
    
    //uint256 public PERIOD_DURATION = 1 days; //PRODUCTION
    //uint256 public PERIOD_DURATION = 1 hours; //RINKEBY
    uint256 public PERIOD_DURATION = 29 days; 

    IERC20 public uniLP;
    IDung  public dung;
    
    uint256 private _totalSupply; 
    mapping(address => uint256) private _balances;

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event Harvested(address indexed user);

    constructor (IDung _dung, IERC20 _unilp) {
    	dung  = _dung;
    	uniLP = _unilp;
    }

    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake(uint256 amount) external {
    	require(amount > 0, "Cannot stake 0");
        
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        uniLP.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
    	require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        uniLP.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

     function exit() external {
        _getReward();
        withdraw(balanceOf(msg.sender));
    }

    function getReward() public {
        _getReward();
        emit Harvested(msg.sender);
    }

    function _getReward() internal updateReward(msg.sender) {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            dung.mint(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function notifyRewardAmount(uint256 reward)
        external
        onlyOwner
        updateReward(address(0))
    {
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(PERIOD_DURATION);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(PERIOD_DURATION);
        }
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(PERIOD_DURATION);
        emit RewardAdded(reward);
    }

}

