// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./access/AccessControlEnumerable.sol";

/**
    ███╗   ███╗ █████╗ ███████╗
    ████╗ ████║██╔══██╗╚══███╔╝
    ██╔████╔██║███████║  ███╔╝ 
    ██║╚██╔╝██║██╔══██║ ███╔╝  
    ██║ ╚═╝ ██║██║  ██║███████╗
    ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝
*/

/// @notice Maz ERC20 for staking
contract Maz is ERC20, ERC20Burnable, AccessControlEnumerable {
    // Access errors
    /// @notice Only admin can access this function
    error Access_OnlyAdmin();

    // Stake errors
    /// @notice Maz minted out
    error Maz_MintedOut();

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @dev This is the max token size for the Maz contract
    uint256 MAX_SUPPLY_SIZE = 10000000000;
    /// @dev This is the next tokenId that can be minted.
    uint256 _nextTokenId = 1;
    /// @dev Thi is the staker minter address
    address stakeMinter;

    /**
     * @dev Grants `MINTER_ROLE` to the staking contract
     * Grants `DEFAULT_ADMIN_ROLE` to the account that deploys contract
    */
    constructor() ERC20("MAZ", "MAZ Coin") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function stakerMint(address _to, uint256 amount) 
        external
        onlyMinter 
        canMintTokens(amount)
        returns (uint256)
    {
        _mint(_to, amount);
        _nextTokenId += amount;
        return _lastMintedTokenId();
    }

    /// @notice Getter for last minted token
    function _lastMintedTokenId() public view returns (uint256) {
        return _nextTokenId - 1;
    }

    /// @notice Setter for stake minter
    function setStakeMinter(address _stakeMinter) external onlyAdmin {
        stakeMinter = _stakeMinter;
        _grantRole(MINTER_ROLE, _stakeMinter);
    }

    /// @notice Getter for stake minter
    function getStakeMinter() public view returns (address) {
        return stakeMinter;
    }

    /// @notice Allows user to mint tokens at a quantity
    modifier canMintTokens(uint256 quantity) {
        if (quantity + _nextTokenId > MAX_SUPPLY_SIZE) {
            revert Maz_MintedOut();
        }

        _;
    }

    /// @notice Only allow for minter with admin access
    modifier onlyMinter() {
        if (!hasRole(MINTER_ROLE, msg.sender)) {
            revert Access_OnlyAdmin();
        }

        _;
    }

    /// @notice Only allow for minter with admin access
    modifier onlyAdmin() {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            revert Access_OnlyAdmin();
        }

        _;
    }
}