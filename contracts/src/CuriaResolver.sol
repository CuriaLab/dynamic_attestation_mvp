// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IEAS, Attestation} from "@eas/contracts/IEAS.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {SchemaResolverUpgradable} from "./eas-upgradable/SchemaResolverUpgradable.sol";

contract CuriaResolver is Initializable, UUPSUpgradeable, OwnableUpgradeable, SchemaResolverUpgradable {
    address public issuer;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(IEAS eas) public initializer {
        __Ownable_init(_msgSender());
        __SchemaResolver_init(eas);
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function setIssuer(address _issuer) external onlyOwner {
        issuer = _issuer;
    }

    function onAttest(Attestation calldata attestation, uint256 value) internal view override returns (bool) {
        return attestation.attester == issuer;
    }

    function onRevoke(Attestation calldata attestation, uint256 value) internal view override returns (bool) {
        return attestation.attester == issuer;
    }
}
