// SPDX-License-Identifier: MIT
// Degen'$ Farm: Collectible NFT game (https://degens.farm)
pragma solidity ^0.7.4;

import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/token/ERC721/IERC721.sol";

contract TokenTester {

    function transfer(IERC721 token, uint[] calldata _deposit, uint[] calldata _withdraw) external {
        for (uint i = 0; i < _deposit.length; i++) {
            token.transferFrom(msg.sender, address(this), _deposit[i]);
        }
        for (uint i = 0; i < _withdraw.length; i++) {
            token.transferFrom(address(this), msg.sender, _withdraw[i]);
        }
    }

    function transfer2(IERC721 token, uint[] calldata _deposit, uint[] calldata _withdraw,
        IERC721 token2, uint[] calldata _deposit2, uint[] calldata _withdraw2) external {
        for (uint i = 0; i < _deposit.length; i++) {
            token.transferFrom(msg.sender, address(this), _deposit[i]);
        }
        for (uint i = 0; i < _withdraw.length; i++) {
            token.transferFrom(address(this), msg.sender, _withdraw[i]);
        }
        for (uint i = 0; i < _deposit2.length; i++) {
            token2.transferFrom(msg.sender, address(this), _deposit2[i]);
        }
        for (uint i = 0; i < _withdraw2.length; i++) {
            token2.transferFrom(address(this), msg.sender, _withdraw2[i]);
        }
    }
}