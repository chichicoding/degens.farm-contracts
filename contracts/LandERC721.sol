// SPDX-License-Identifier: MIT
// Degen Farm. Collectible NFT game
pragma solidity ^0.7.4;

import "./ERC721URIStorage.sol";
import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/access/Ownable.sol";

//v0.0.1
contract Land is ERC721URIStorage, Ownable {

    uint256[] private _allTokens;

    mapping(address => bool) public trusted_markets;
    event TrustedMarket(address indexed _market, bool _state);

    constructor(string memory name_,
        string memory symbol_) ERC721(name_, symbol_)  {
    }

    function mintWithURI(
        address to,
        uint256 tokenId,
        string memory _tokenURI
    ) external onlyOwner {

        _mint(to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        _allTokens.push(tokenId);
    }

    function burn(uint256 tokenId) external {
        _burn(tokenId);
    }

    //TODO Remove if not usefull
    function setURI(uint256 tokenId, string memory _tokenURI) external {
        require(ownerOf(tokenId) == msg.sender, 'Only owner can change URI.');
        _setTokenURI(tokenId, _tokenURI);
    }

    function setTrustedMarket(address _market, bool _state) external onlyOwner {
        trusted_markets[_market] = _state;
        emit TrustedMarket(_market, _state);
    }

    function getUsersTokens(address _owner) external view returns (uint256[] memory) {
        //We can return only uint256[] memory, but we cant use push
        // with memory arrays.
        //https://docs.soliditylang.org/en/v0.7.4/types.html#allocating-memory-arrays
        //So first we need calc size of array to be returned
        //!!!!This will work  not for all _allTokens.length, checked for ~700
        uint16 n = 0;
        for (uint16 i=0; i<_allTokens.length; i++) {
            if (ownerOf(_allTokens[i]) == _owner) {
                n++;
            }
        }
        uint256[] memory result = new uint256[](n);
        for (uint16 i=0; i<_allTokens.length; i++) {
            if (ownerOf(_allTokens[i]) == _owner) {
                result[n-1]=_allTokens[i];
                n--;
            }
        }
        return  result;
    }

    function baseURI() public view  override returns (string memory) {
        return 'https://degens.farm/V1/lands/';
    }

    /**
     * @dev Overriding standart function for gas safe traiding with trusted parts like DegenFarm
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `caller` must be added to trustedMarkets.
     */
    function transferFrom(address from, address to, uint256 tokenId) public override {
        if  (trusted_markets[msg.sender]) {
            _transfer(from, to, tokenId);
        } else {
            super.transferFrom(from, to, tokenId);
        }

    }

}
