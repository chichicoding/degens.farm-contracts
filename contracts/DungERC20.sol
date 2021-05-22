// SPDX-License-Identifier: MIT
// Degen Farm. Collectible NFT game
pragma solidity ^0.7.4;

import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/token/ERC20/ERC20.sol";
import "./MinterRole.sol";

contract Dung is ERC20, MinterRole {
	using SafeMath for uint256;

    //address public trustedSpender; //Must be set at deploy with Inventory Address
    //uint256 public constant MAX_SUPPLY = 3900e18;
    uint256 public constant INITIAL_MINT = 1000000e33;
    uint256 public constant AIRDROPS     = 50000e33;
    uint256 public constant ADVISORS     = 10000e33;

    constructor()
    ERC20("Degens Farm Dung", "DUNG")
    MinterRole(msg.sender)
    {
        _mint(msg.sender, INITIAL_MINT.add(AIRDROPS).add(ADVISORS));

    }

    function mint(address to, uint256 amount) external onlyMinter {
        //require(totalSupply() <= MAX_SUPPLY.sub(amount), "MAX_SUPPLY exceed!");
        _mint(to, amount);
    }

    //REmove if note used
    function burn(address to, uint256 amount) external onlyMinter {
        _burn(to, amount);
    }

    /**
     * @dev Overriding standart function for gas safe swap with Inventory
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least (exclude trustedSpender)
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        if  (isMinter(msg.sender)==false) {
            return super.transferFrom(sender, recipient, amount);
        } else {
           _transfer(sender, recipient, amount);
           return true;
        }

    }

     /**
     * @dev Owner can claim any tokens that transfered
     * to this contract address
     */
    function reclaimToken(ERC20 token) external onlyMinter {
        require(address(token) != address(0));
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
    }

    /**
     * @dev This function implement proxy for befor transfer hook form OpenZeppelin ERC20.
     *
     * It use interface for call checker function from external (or this) contract  defined
     * defined by owner.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        require(to != address(this), "This contract not accept tokens" );
    }

}
