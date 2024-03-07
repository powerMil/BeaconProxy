// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "./BoxBeacon.sol";
import "./BoxV1.sol";

//Creates instances of upgradeable contracts using the Beacon Proxy Pattern.
//Relies on the contract BoxBeacon for managing the logic contract addresses
contract Factory {
    mapping(uint256 => address) private boxes; // maps the instances of upgradeable contracts to addresses

    BoxBeacon immutable beacon; // Calls the address of BoxBeacon

    constructor(address _logic) {
        beacon = new BoxBeacon(_logic);
    }

    //Creates a new instance of an upgradeable contract.Uses BeaconProxy to create a new BeaconProxy.
    //Passes the address of the Beacon and it calls the initialiazation parameter for BoxV1

    function create(
        string calldata _name,
        uint256 _vaLue,
        uint256 x
    ) external returns (address) {
        BeaconProxy proxy = new BeaconProxy(
            address(beacon),
            abi.encodeWithSelector(
                BoxV1(address(0)).initialize.selector,
                _name,
                _vaLue
            )
        );
        // The proxy address is stored in the boxes mapping variable at index x
        boxes[x] = address(proxy);
        return address(proxy);
    }

    function getImplementation() public view returns (address) {
        return beacon.implementation();
    }

    function getBeacon() public view returns (address) {
        return address(beacon);
    }

    function getBox(uint256 x) public view returns (address) {
        return boxes[x];
    }
}
