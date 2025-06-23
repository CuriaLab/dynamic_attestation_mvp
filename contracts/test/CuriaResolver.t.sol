// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {CuriaResolver, ICuriaResolver} from "@dynamic-attestation/src/CuriaResolver.sol";
import {ISchemaResolver} from "@eas/contracts/resolver/ISchemaResolver.sol";
import {ISchemaRegistry, SchemaRegistry} from "@eas/contracts/SchemaRegistry.sol";
import {
    IEAS,
    EAS,
    AttestationRequest,
    AttestationRequestData,
    Attestation,
    RevocationRequestData,
    RevocationRequest
} from "@eas/contracts/EAS.sol";
import {AccessDenied} from "@eas/contracts/Common.sol";

contract CuriaResolverTest is Test {
    CuriaResolver public resolver;
    IEAS public eas;
    ISchemaRegistry public schemaRegistry;
    address public owner = address(0xbeef);
    address public issuer = address(0xcafe);
    address public anon = address(0xdead);
    bytes32 public schemaId;
    string public schema = "string rank,bool includePartialDelegatation,string date";

    function setUp() public {
        schemaRegistry = new SchemaRegistry();
        eas = new EAS(schemaRegistry);

        // Deploy resolver and set issuer
        vm.startPrank(owner);
        resolver = new CuriaResolver(eas);
        resolver.setIssuer(issuer, true);
        vm.stopPrank();

        // Register schema
        schemaId = schemaRegistry.register(schema, resolver, true);
        console.log("eas", address(eas));
    }

    function testAttest() public {
        AttestationRequestData memory data = AttestationRequestData({
            recipient: anon,
            revocable: true,
            refUID: bytes32(0),
            data: abi.encode("top100", true, "2024-11-09"), //  fixed encoding
            expirationTime: 0,
            value: 0
        });

        AttestationRequest memory request = AttestationRequest({
            schema: schemaId,
            data: data
        });

        // Try with non-issuer (should fail)
        vm.startPrank(anon);
        vm.expectRevert(ICuriaResolver.NotIssuer.selector);
        eas.attest(request);
        vm.stopPrank();

        // Try with issuer (should pass)
        vm.startPrank(issuer);
        bytes32 attestId = eas.attest(request);
        vm.stopPrank();

        // Assert attestation
        Attestation memory attestation = eas.getAttestation(attestId);
        assertEq(attestation.attester, issuer);
        assertEq(attestation.recipient, anon);
        assertEq(attestation.schema, schemaId);
    }

    function testRevoke() public {
        AttestationRequestData memory data = AttestationRequestData({
            recipient: anon,
            revocable: true,
            refUID: bytes32(0),
            data: abi.encode("top100", true, "2024-11-09"), //  fixed encoding
            expirationTime: 0,
            value: 0
        });

        AttestationRequest memory request = AttestationRequest({
            schema: schemaId,
            data: data
        });

        // Issuer attests
        vm.startPrank(issuer);
        bytes32 attestId = eas.attest(request);
        vm.stopPrank();

        // Try to revoke from non-issuer (should fail)
        RevocationRequestData memory revocationData = RevocationRequestData({
            uid: attestId,
            value: 0
        });

        RevocationRequest memory revocation = RevocationRequest({
            schema: schemaId,
            data: revocationData
        });

        vm.startPrank(anon);
        vm.expectRevert(AccessDenied.selector);
        eas.revoke(revocation);
        vm.stopPrank();

        // Issuer revokes (should pass)
        vm.startPrank(issuer);
        eas.revoke(revocation);
        vm.stopPrank();

        Attestation memory attestation = eas.getAttestation(attestId);
        assertEq(attestation.revocationTime, block.timestamp);
    }
}
