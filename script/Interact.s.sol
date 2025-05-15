// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script {
    error __ClaimAirdrop_InvalidSignatureLength();
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 PROOF_ONE = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 PROOF_TWO = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [PROOF_ONE, PROOF_TWO];
    bytes private SIGNATURE = hex"24bb5b6a23f2f5bbe483df3eee382641096be04c90d87ce237395a72088348bc0888d54b215b8db70e3c25bf757734fcd91151a0da4e303108d9e6812c7c15261b";
    function claimAirdrop(address airdropContract) public {
        vm.startBroadcast();
        uint8 v;
        bytes32 r; 
        bytes32 s;
        (v, r, s ) = splitSignature(SIGNATURE);
        MerkleAirdrop(airdropContract).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, proof, v, r, s);
        vm.stopBroadcast();
    }
    function run() external{
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }

    function splitSignature(bytes memory sig) public view returns (uint8 v, bytes32 r, bytes32 s) {
        if(sig.length != 65){
            revert __ClaimAirdrop_InvalidSignatureLength();
        }
        assembly {
            r := mload(add(sig, 0x20))
            s := mload(add(sig, 0x40))
            v := byte(0, mload(add(sig, 0x60)))
        }
    }
}