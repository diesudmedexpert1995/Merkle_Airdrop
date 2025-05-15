// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.24 <0.9.0;
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";


contract MerkleAirdrop is EIP712 {
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();
    using SafeERC20 for IERC20;

    struct AirdropClaim {
        address account;
        uint256 amount;
    }
    
    bytes32 public immutable i_merkleRoot;
    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account,uint256 amount)"); // 0x810786b83997ad50983567660c1d9050f79500bb7c2470579e75690d45184163;
    IERC20 public immutable i_airdropToken;
    mapping (address => bool) private s_hasClaimed;

    event Claimed(address indexed account, uint256 indexed amount);

    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("Merkle Airdrop", "1"){
        i_airdropToken = airdropToken;
        i_merkleRoot = merkleRoot;
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }

    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount}))));
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s) external {
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        
        bytes32 digest = getMessageHash(account, amount);

        if(!_isValidSignature(account, digest, v, r, s)){
            revert MerkleAirdrop__InvalidSignature();
        }

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if(!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)){
            revert MerkleAirdrop__InvalidProof();
        }
        
        s_hasClaimed[account] = true;
        i_airdropToken.safeTransfer(account, amount);
        emit Claimed(account, amount);
    }

    function _isValidSignature(address expectedSigner, bytes32 digest, uint8 v, bytes32 r, bytes32 s) internal pure returns(bool) {
        (address actualSigner, ,) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner != address(0) && actualSigner == expectedSigner;
    }
}