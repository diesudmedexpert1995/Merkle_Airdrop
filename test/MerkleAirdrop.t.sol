// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.24 < 0.9.0;

import {Test, console} from "forge-std/Test.sol";
import {MangoToken} from "../src/MangoToken.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {ZkSyncChainChecker} from "@foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";
contract MerkleTest is Test, ZkSyncChainChecker {
    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public AMOUNT_TO_SEND = AMOUNT_TO_CLAIM*4;
    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proofOne, proofTwo];
    MangoToken mangoToken;
    MerkleAirdrop mangoAirdrop;
    address user;
    uint256 userKey;

    address public gasPayer;

    function setUp() public {
        if(!isZkSyncChain()){
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (mangoAirdrop, mangoToken) = deployer.run();
        }else {
            mangoToken = new MangoToken();
            mangoAirdrop = new MerkleAirdrop(ROOT, mangoToken);
            mangoToken.mint(address(this), AMOUNT_TO_SEND);
            mangoToken.transfer(address(mangoAirdrop), AMOUNT_TO_SEND);
        }
        (user, userKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gassPayer");
    }

    function testUserCanClaim() public {
        uint256 startingBalance = mangoToken.balanceOf(user);
        bytes32 digest = mangoAirdrop.getMessageHash(user, AMOUNT_TO_CLAIM);
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v,r,s) = vm.sign(userKey, digest);
        vm.prank(gasPayer);
        mangoAirdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        uint256 endingBalance = mangoToken.balanceOf(user);

        console.log("Ending balance: %d", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);

    }
}