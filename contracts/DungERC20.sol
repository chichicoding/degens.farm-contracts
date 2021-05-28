// SPDX-License-Identifier: MIT
// Degen'$ Farm: Collectible NFT game (https://degens.farm)
pragma solidity ^0.7.4;

import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/token/ERC20/ERC20.sol";
import "./MinterRole.sol";

contract Dung is ERC20, MinterRole {
	using SafeMath for uint256;

    uint256 public constant INITIAL_MINT = 1000000e33;

    constructor()
        ERC20("Degen$ Farm Dung", "DUNG")
        MinterRole(msg.sender)
    {
        _mint(msg.sender, INITIAL_MINT);
    }

    function mint(address to, uint256 amount) external onlyMinter {
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
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
