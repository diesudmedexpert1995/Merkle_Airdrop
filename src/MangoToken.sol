// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.24 <0.9.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MangoToken is ERC20, Ownable {
    constructor() ERC20("Mango Token", "MANGO") Ownable(msg.sender) {}

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }
}