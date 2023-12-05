// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

interface IBPContract {

    function protect(address sender, address receiver, uint256 amount) external;

}

contract SingSingToken is ERC20, ERC20Burnable, Pausable, Ownable {
    using SafeMath for uint256;
    uint256 private totalTokens;

    IBPContract public bpContract;

    bool public bpEnabled;
    bool public bpDisabledForever;

    constructor() ERC20("SingSing Token", "SING") {
        totalTokens = 2400000000 * 10**uint256(decimals());
        _mint(owner(), totalTokens); // total supply fixed at 2.4 billion tokens
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function pause() public whenNotPaused {
        _pause();
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function unpause() public whenPaused {
        _unpause();
    }

    function setBPContract(address addr)
        public
        onlyOwner
    {
        require(addr != address(0), "BP address cannot be 0x0");

        bpContract = IBPContract(addr);
    }

    function setBPEnabled(bool enabled)
        public
        onlyOwner
    {
        bpEnabled = enabled;
    }

    function setBPDisableForever()
        public
        onlyOwner
    {
        require(!bpDisabledForever, "Bot protection disabled");

        bpDisabledForever = true;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override
    {
        if (bpEnabled && !bpDisabledForever) {
            bpContract.protect(from, to, amount);
        }

        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
}