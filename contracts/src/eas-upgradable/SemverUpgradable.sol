// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract SemverUpgradable is Initializable {
    // Contract's major version number.
    uint256 private _major;

    // Contract's minor version number.
    uint256 private _minor;

    // Contract's patch version number.
    uint256 private _path;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(uint256 major, uint256 minor, uint256 patch) public initializer {
        _major = major;
        _minor = minor;
        _path = patch;
    }

    /// @notice Returns the full semver contract version.
    /// @return Semver contract version as a string.
    function version() external view returns (string memory) {
        return
            string(
                abi.encodePacked(Strings.toString(_major), ".", Strings.toString(_minor), ".", Strings.toString(_path))
            );
    }
}
