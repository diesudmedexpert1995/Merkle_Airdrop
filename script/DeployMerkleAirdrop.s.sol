// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {MangoToken} from "../src/MangoToken.sol";
import {Script} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public AMOUNT_TO_TRANSFER = (25 * 1e18)*4;

    function deployMerkleAirdrop() public returns (MerkleAirdrop, MangoToken ) {
        vm.startBroadcast();
        MangoToken mangoToken = new MangoToken();
        MerkleAirdrop merkleAirdrop = new MerkleAirdrop(ROOT, IERC20(mangoToken));
        mangoToken.mint(mangoToken.owner(), AMOUNT_TO_TRANSFER);
        IERC20(mangoToken).transfer(address(merkleAirdrop), AMOUNT_TO_TRANSFER);
        vm.stopBroadcast();
        return(merkleAirdrop, mangoToken);
    }

    function run() external returns (MerkleAirdrop merkleAirdrop, MangoToken mangoToken) {
        return deployMerkleAirdrop();
    }
}