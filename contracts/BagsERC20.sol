// SPDX-License-Identifier: MIT
// Degen Farm. Collectible NFT game
pragma solidity ^0.7.4;

import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/token/ERC20/ERC20.sol";
import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/access/Ownable.sol";

contract Bags is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 immutable public MAX_BAGS;

    constructor(uint256 _maxBags)
        ERC20("Degens Farm Bags", "BAGZ")
    {
        MAX_BAGS = _maxBags;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        require(totalSupply() <= MAX_BAGS.sub(amount), "MAX bags amount exceed!");
        _mint(to, amount);
    }

    function burn(address to, uint256 amount) external onlyOwner {
        _burn(to, amount);
    }

    /**
     * @dev Owner can claim any tokens that transfered
     * to this contract address
     */
    function reclaimToken(ERC20 token) external onlyOwner {
        require(address(token) != address(0));
        uint256 balance = token.balanceOf(address(this));
        token.transfer(owner(), balance);
    }

    /**
     * @dev This function implement proxy for before transfer hook form OpenZeppelin ERC20.
     *
     * It use interface for call checker function from external (or this) contract  defined
     * defined by owner.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        require(to != address(this), "This contract not accept tokens" );
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view override returns (uint8) {
        return 0;
    }
}
