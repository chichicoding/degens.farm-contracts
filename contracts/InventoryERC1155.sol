// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;

import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/token/ERC1155/ERC1155.sol";
import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/access/Ownable.sol";
import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/utils/Strings.sol";
//For initial change inventary for DUNG
import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/token/ERC20/IERC20.sol";

//v0.0.1
contract InventaryERC1155 is  ERC1155 {
    using Strings for uint256;
    using SafeMath for uint256;

    enum   InventaryType {Pipe, Hat, Carrot, Shovel, Rake, Pitchfork}
    struct Inventary {
        InventaryType itype;
        uint256       priceDung;
        uint256       incProbability;
    }

    string constant BASE_METADATA_URL= "https://nft.iber.group/degenfarm/V1/inventary/";

    address public dungERC20;
    //Token id to Properties
    mapping(uint8 => Inventary) public inventaryProperties;


    constructor (string memory uri_) ERC1155(uri_) {
        _mint(address(this), 0, 5, bytes('0')); //Hat
        inventaryProperties[0] = Inventary(InventaryType.Pipe,      200e18, 20);
        _mint(address(this), 1, 3, bytes('0'));
        inventaryProperties[1] = Inventary(InventaryType.Hat,       180e18, 15);
        _mint(address(this), 2, 5, bytes('0'));
        inventaryProperties[2] = Inventary(InventaryType.Carrot,    150e18, 12);
        _mint(address(this), 3, 5, bytes('0'));
        inventaryProperties[3] = Inventary(InventaryType.Shovel,    120e18, 10);
        _mint(address(this), 4, 5, bytes('0'));
        inventaryProperties[4] = Inventary(InventaryType.Rake,      120e18, 10);
        _mint(address(this), 5, 3, bytes('0'));
        inventaryProperties[5] = Inventary(InventaryType.Pitchfork, 120e18, 10);
    }

    function dungSwap(uint8 _item, uint256 _amount) external {
        require(IERC20(dungERC20).balanceOf(msg.sender) >=
            _amount.mul(inventaryProperties[_item].priceDung),
            "Insufficient DUNG!"
        );
        IERC20(dungERC20).transferFrom(
            msg.sender,
            address(this),
            _amount.mul(inventaryProperties[_item].priceDung)
        );
        safeTransferFrom(address(this), msg.sender, _item, _amount, bytes('0'));
    }


    function uri(uint256 _id) external view override returns (string memory) {
        return string(abi.encodePacked(BASE_METADATA_URL, _id.toString()));
    }

    function getToolBoost(uint8 _item) external view returns (uint256) {
        return inventaryProperties[_item].incProbability;
    }

}


