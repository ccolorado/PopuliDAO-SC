//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IWorldID } from "./Interfaces/IWorldID.sol";

import "hardhat/console.sol";

contract WorldVerify {

    /// @dev The contract's external nullifier hash
    uint256 internal immutable externalNullifier;

    /// @dev The World ID group ID (always 1)
    uint256 internal immutable groupId = 1;

    /// @dev The World ID instance that will be used for verifying proofs
    IWorldID internal immutable worldId;

    struct DAOParticipant {
        address WalletAddress;
    }

    mapping(address => uint256) AddressToWorldID;
    mapping(uint256 => address) WorldIDToAddress;
    /// @dev Whether a nullifier hash has been used already. Used to guarantee an action is only performed once by a single person
    mapping(uint256 => bool) internal nullifierHashes;

    event DAOParticipantRegistered(address indexed WalletAddress);

    ////////////////////////////////////////////////////////////////////////////////
    ///                                  ERRORS                                ///
    //////////////////////////////////////////////////////////////////////////////

    error WorldIDAlreadyUsed();

    /// @notice Thrown when attempting to reuse a nullifier
    error InvalidNullifier();

    constructor(address _worldId) {
        worldId = IWorldID(_worldId);
    }

    /// @dev Registers a new account
    /// @param signal An arbitrary input from the user, usually the user's wallet address (check README for further details)
    /// @param root The root of the Merkle tree (returned by the JS widget).
    /// @param nullifierHash The nullifier hash for this proof, preventing double signaling (returned by the JS widget).
    /// @param proof The zero-knowledge proof that demonstrates the claimer is registered with World ID (returned by the JS widget).
    function registerAccount(
        address signal,
        uint256 root,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) public {
        // First, we make sure this person hasn't done this before
        if (nullifierHashes[nullifierHash]) revert InvalidNullifier();

        uint256 _worldId = AddressToWorldID[signal];
        address _registerdAddress = WorldIDToAddress[_worldId];

        console.log("_woldId", _worldId);
        console.log("_registerdAddress", _registerdAddress);

        require( _registerdAddress == address(0), "WorldID already registered");

        // We now verify the provided proof is valid and the user is verified by World ID
        // NOTE: encodePackad is wrong
        // worldId.verifyProof(
        //     root,
        //     groupId,
        //     abi.encodePacked(signal).hashToField(),
        //     nullifierHash,
        //     externalNullifier,
        //     proof
        // );

        // We now record the user has done this, so they can't do it again (proof of uniqueness)
        nullifierHashes[nullifierHash] = true;

        // TODO: is wrong and does nothign
        //WorldIDToAddress[signal] != 0;
        // TODO: Get the new address World Id
        //WorldIDToAddress[NEW_ADDRESS_WORLD_ID] = signal;

        emit DAOParticipantRegistered(signal);

        // Finally, execute your logic here, for example issue a token, NFT, etc...
        // Make sure to emit some kind of event afterwards!
    }

}
