// SPDX-License-Identifier: MIT
// Degen'$ Farm: Collectible NFT game (https://degens.farm)
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

import "./DegensFarmBase.sol";

contract DegenFarm is DegenFarmBase {

    uint8   constant public CREATURE_TYPE_COUNT= 20;  // how much creatures types may be used
    uint256 constant public FARMING_DURATION   = 168 hours;
    uint256 constant public TOOL_UNSTAKE_DELAY = 1 weeks;
    uint16  constant public NORMIE_COUNT_IN_TYPE = 100;
    uint16  constant public CHAD_COUNT_IN_TYPE = 20;
    uint16  constant public MAX_LANDS = 2500;

    constructor (
        address _land,
        address _creatures,
        address _inventory,
        address _bagstoken,
        address _dungtoken,
        IEggs _eggs
    )
        DegenFarmBase(_land, _creatures, _inventory, _bagstoken, _dungtoken, _eggs)
    {
        require(CREATURE_TYPE_COUNT <= CREATURE_TYPE_COUNT_MAX, "CREATURE_TYPE_COUNT is greater than CREATURE_TYPE_COUNT_MAX");
    }

    function getCreatureTypeCount() override internal view returns (uint16) {
        return CREATURE_TYPE_COUNT;
    }

    function getFarmingDuration() override internal view returns (uint) {
        return FARMING_DURATION;
    }

    function getNormieCountInType() override internal view returns (uint16) {
        return NORMIE_COUNT_IN_TYPE;
    }

    function getChadCountInType() override internal view returns (uint16) {
        return CHAD_COUNT_IN_TYPE;
    }

    function getMaxLands() override internal view returns (uint16) {
        return MAX_LANDS;
    }

    function getToolUnstakeDelay() override internal view returns (uint) {
        return TOOL_UNSTAKE_DELAY;
    }

}
