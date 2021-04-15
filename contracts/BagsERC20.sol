// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;

import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/token/ERC20/ERC20.sol";
import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/access/Ownable.sol";

contract Bags is ERC20,  Ownable {
    using SafeMath for uint256;

    uint256 immutable public MAX_BAGS;
    constructor(uint256 _maxBags)
        ERC20("Degen's Farm Bags", "BAGZ")
    {
        MAX_BAGS = _maxBags;
    }

    function mint(address to, uint256 amount ) external onlyOwner {
        require(totalSupply() <= MAX_BAGS.sub(amount), "MAX bags amount exceed!");
        _mint(to, amount);
    }

    function burn(address to, uint256 amount ) external onlyOwner {
        _burn(to, amount);
    }

}
