// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

//Follows the proxy pattern to seperate the contract's logic from its storage
// Holds the address of the current logic contract and facilitates a new logic contract while preserving the contract state
contract BoxBeacon {
    UpgradeableBeacon immutable beacon; // cannot be changed

    address public logic; // holds the address of the current logic contract

    //Sets the beacon variable to the newly created UpgradeableBeacon instance.Making it immutable
    constructor(address _logic) {
        beacon = new UpgradeableBeacon(_logic, address(this));
        logic = _logic;
    }

    //Allows upgrading the logic contract to a new address
    function update(address _logic) public {
        beacon.upgradeTo(_logic);
        logic = _logic;
    }

    //Returns the current implementation address stored in the upgradeableBeacon
    function implementation() public view returns (address) {
        return beacon.implementation();
    }
}
