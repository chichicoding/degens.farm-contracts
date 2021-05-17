// SPDX-License-Identifier: MIT
// Degen Farm. Collectible NFT game
pragma solidity ^0.7.4;

import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/access/Ownable.sol";
import "./BagsERC20.sol";

contract BagSale is Ownable {
    using SafeMath for uint256; 

    //TODO!!!!!!!!!!UNCOMMENT THIS BEFORE PRODUCTION and set value
    //uint256 constant SALE_AFTER = 0; //!!!!! Set in production!!!!
    Bags immutable bagsContract;
    
    //TODO!!!!!!!!!! REMOVE THIS BEFORE  PRODUCTIN
    uint256 public SALE_AFTER = 0;
    uint256 public bagPrice;
    uint256 public weiRaised;

    uint256 public A = 10028;        //multiplied on 1e4
    uint256 public percentWant = 3;  //like slippage in Uniswap

    event BagBought(address indexed _buyer, uint256 _wantPrice, uint256 _boughtPrice, uint256 amount);
 
    /**
     * @dev Set some initial params for sale.
     *
     * Requirements:
     *
     * - `_erc20` Bags ERC20 contract address.
     */
    constructor(Bags _erc20) {
        bagsContract = _erc20;
        bagPrice = 1e17; //initial price value (B in formula)
    }

    /**
     * @dev Call this Function for buy bag for ether with  _wantPrice. Every
     * next purchase will be more expensive. So you can tell contract price
     * that you may pay. And if diff is less then 3% you will buy with your price
     *
     * @param _wantPrice - desired reasonable price
     */
    function buyBag(uint256 _wantPrice) external payable {
        require(block.timestamp > SALE_AFTER, "Can't by before SALE_AFTER");
        require(msg.value >= bagPrice, "Need more ether!");
        uint256 mintAmount = msg.value.mul(10**bagsContract.decimals()).div(bagPrice);
        // require(mintAmount <= 10e18, "Cant't buy more than 10 per tx!");
        bagsContract.mint(msg.sender, mintAmount);
        weiRaised = weiRaised.add(msg.value);
        emit BagBought(msg.sender, _wantPrice, bagPrice, mintAmount);
    }

    /**
     * @dev Just withdraw ether to owner
    */
    function withdraw() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    
    //TODO Remove before PRODUCTION  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    function setSaleStart(uint256 _start_date) external onlyOwner {
        SALE_AFTER = _start_date;
    }

    function setBagPrice(uint256 _bagPrice) external onlyOwner {
        bagPrice = _bagPrice;
    }


    /**
     * @dev Returns amount of bags that available for sale yet
    */
    function bagsAvailable() external view returns (uint256) {
        return bagsContract.MAX_BAGS().sub(bagsContract.totalSupply());
    }

    /**
     * @dev Returns price for next bag in current moment
    */
    function nextBagPrice() external view returns (uint256) {
        return _nextPrice(1);
    }

    /**
     * @dev Function returns tuple with next price  according to the bonding 
     * curve (1) and left amount of BAGs token (2)
     *
     * @return (uint256, uint256)
     */
    function howMuch() external view returns (uint256, uint256) {
        return (_nextPrice(1), bagsContract.MAX_BAGS().sub(bagsContract.totalSupply()));
    }

    /**
     * @dev Returns price after `_bagsCount` will bought
     *.
     * @param _bagsCount - bags that will  bought.
    */
    function _nextPrice(uint256 _bagsCount) internal view returns (uint256) {
        //Because last_price expressed in wei we dont need mul(1e18)
        //but still need div(1e4) - see comment above near A and B declaration
        //uint256 _price = last_price.mul(A**_bagsCount).div(10**(4*_bagsCount));
        return bagPrice;
    }
}