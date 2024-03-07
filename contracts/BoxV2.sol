// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract BoxV2 is Initializable {
    string public name;
    uint256 public value;
    
    function initialize(string memory _name, uint256 _value) public initializer {
        name = _name;
        value = _value;
    }

    function down() public {
        value--;
    }

    function up() public {
        value++;
    }

}