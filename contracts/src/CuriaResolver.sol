// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {IEAS, Attestation} from "@eas/contracts/IEAS.sol";
import {ICuriaResolver} from "dynamic-attestation/src/ICuriaResolver.sol";
import {SchemaResolver} from "@eas/contracts/resolver/SchemaResolver.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title CuriaResolver
/// @notice Resolver that checks if an address is an authorized issuer for attestations
/// @dev Inherits SchemaResolver and Ownable for access control and attestation resolution
contract CuriaResolver is ICuriaResolver, Ownable, SchemaResolver {
    /// @notice Mapping to track allowed issuers
    mapping(address => bool) public isIssuer;

    /// @notice Emitted when an issuer's status is updated
    /// @param account The address of the issuer
    /// @param enabled The new status of the issuer (true if enabled)
    event IssuerUpdated(address indexed account, bool enabled);

    /// @notice Custom error for unauthorized issuers
    error NotIssuer();

    /// @notice Constructor
    /// @param eas The EAS contract address
    constructor(IEAS eas) SchemaResolver(eas) {}

    /// @notice Checks if an address is a valid issuer
    /// @param attestation The attestation structure containing the issuer
    function _checkIssuer(Attestation calldata attestation) internal view {
        address attestor = attestation.attester;
        if (!isIssuer[attestor]) {
            revert NotIssuer();
        }
    }

    /// @notice Set or revoke issuer status for an address
    /// @param account The address to set status for
    /// @param enable True to add as issuer, false to remove
    function setIssuer(address account, bool enable) external override onlyOwner {
        require(account != address(0), "Issuer cannot be zero address");
        isIssuer[account] = enable;
        emit IssuerUpdated(account, enable);
    }

    /// @inheritdoc SchemaResolver
    /// @dev Checks issuer when attesting
    function onAttest(Attestation calldata attestation, uint256 value)
        internal
        view
        override
        returns (bool)
    {
        _checkIssuer(attestation);
        return true;
    }

    /// @inheritdoc SchemaResolver
    /// @dev No issuer check on revoke, always returns true
    function onRevoke(Attestation calldata /*attestation*/, uint256 /*value*/)
        internal
        view
        override
        returns (bool)
    {
        return true;
    }
}
