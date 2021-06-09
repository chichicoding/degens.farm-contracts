// SPDX-License-Identifier: MIT
// Degen'$ Farm: Collectible NFT game (https://degens.farm)
pragma solidity ^0.7.4;

import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/token/ERC1155/ERC1155.sol";
import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/access/Ownable.sol";
import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/utils/Strings.sol";
//For initial change inventory for DUNG
import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/token/ERC20/IERC20.sol";

interface IDungBurn is IERC20 {
    function burn(
        uint256 amount 
    ) external;
}

contract InventoryERC1155 is ERC1155, Ownable {
    using Strings for uint256;
    using SafeMath for uint256;

    uint256 constant public TOOL_TYPE_COUNT = 6;
    enum   InventoryType {Hat, Pipe, Moonshine, Shovel, Rake, Pitchfork}

    struct Inventory {
        InventoryType itype;
        uint256       priceDung;
        uint16        incProbability;
    }
    
    string constant BASE_METADATA_URL = "https://degens.farm/meta/inventory/";
    
    address public dungERC20;
    //Token id to Properties
    mapping(uint8 => Inventory) public inventoryProperties;

    
    /**
     * @dev we use uri_ here for Compatibility with
     * https://eips.ethereum.org/EIPS/eip-1155#metadata
     * 
     */
    constructor (string memory uri_, address _dungToken)
        ERC1155(uri_)
    {
        dungERC20 = _dungToken;
        register(InventoryType.Hat,       25e18 ether, 5, 20);
        register(InventoryType.Pipe,      15e18 ether, 10, 10);
        register(InventoryType.Moonshine, 7e18 ether,  25, 8);
        register(InventoryType.Shovel,    5e18 ether,  50, 5);
        register(InventoryType.Rake,      2500e15 ether, 30, 4);
        register(InventoryType.Pitchfork, 1e18 ether,  100, 2);
    }

    function register(InventoryType _type, uint price, uint count, uint16 boost) internal {
        _mint(address(this), uint8(_type), count, bytes('0'));
        inventoryProperties[uint8(_type)] = Inventory(_type, price, boost);
    }

    function dungSwap(uint8 _item, uint256 _amount) external {
        require(_amount != 0, "Cant swap zero dung");
        require(IERC20(dungERC20).balanceOf(msg.sender) >= 
            _amount.mul(inventoryProperties[_item].priceDung), 
            "Insufficient DUNG!"
        );
        IERC20(dungERC20).transferFrom(
            msg.sender, 
            address(this), 
            _amount.mul(inventoryProperties[_item].priceDung)
        );
        IDungBurn(dungERC20).burn(_amount.mul(inventoryProperties[_item].priceDung));

        this.safeTransferFrom(address(this), msg.sender, _item, _amount, bytes('0'));
    }

    /*
     * @dev this is not full standard bot common use of 1155 implementation
     */
    function uri2(uint256 _id) external view  returns (string memory) {
        return string(abi.encodePacked(BASE_METADATA_URL, _id.toString()));
    }

    function getToolBoost(uint8 _item) external view returns (uint16) {
        return inventoryProperties[_item].incProbability;
    }

    function getMarketInfo() external view returns (uint[] memory result) {
        result = new uint[](TOOL_TYPE_COUNT*3);
        for (uint8 i = 0; i < TOOL_TYPE_COUNT; i++) {
            result[i*3 + 0] = inventoryProperties[i].priceDung;
            result[i*3 + 1] = inventoryProperties[i].incProbability;
            result[i*3 + 2] = balanceOf(address(this), i);
        }
    }

}
