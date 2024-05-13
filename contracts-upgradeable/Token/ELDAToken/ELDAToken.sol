// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ELDAToken is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("Eldarune", "ELDA") {
        _mint(msg.sender, 600000000 * 10 ** decimals());
    }
}