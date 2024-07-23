// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Maz.sol" ;
import "./access/AccessControlEnumerable.sol";

/**
    ███╗   ███╗ █████╗ ███████╗    ███████╗████████╗ █████╗ ██╗  ██╗███████╗██████╗ 
    ████╗ ████║██╔══██╗╚══███╔╝    ██╔════╝╚══██╔══╝██╔══██╗██║ ██╔╝██╔════╝██╔══██╗
    ██╔████╔██║███████║  ███╔╝     ███████╗   ██║   ███████║█████╔╝ █████╗  ██████╔╝
    ██║╚██╔╝██║██╔══██║ ███╔╝      ╚════██║   ██║   ██╔══██║██╔═██╗ ██╔══╝  ██╔══██╗
    ██║ ╚═╝ ██║██║  ██║███████╗    ███████║   ██║   ██║  ██║██║  ██╗███████╗██║  ██║
    ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝    ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
*/

contract StakingMinter is AccessControlEnumerable {
    // Access errors
    /// @notice Only admin can access this function
    error Access_OnlyAdmin();

    // Stake errors
    /// @notice Only update if token is added into staking contract
    error Not_CreatedYet();
    /// @notice Sale is inactive
    error Stake_Inactive();
    /// @notice Presale is inactive
    error PreStake_Inactive();

    /// @notice New exchange rate has been created
    /// @dev To access new created exchange rate, use getter function.
    /// @param createdAddress Created by admin
    event ExchangeRateCreated(address indexed createdAddress, uint256 rate);

    /// @notice Exchange rate has been updated
    /// @dev To access updated exchange rate, use getter function.
    /// @param updatedAddress Updated by admin
    event ExchangeRateUpdated(address indexed updatedAddress, uint256 rate);

    /// @notice Staker has been minted in public mode
    /// @dev To access public minted info, use getter function.
    /// @param staker staker
    /// @param amount mint amount
    event PublicMinted(address indexed staker, uint256 amount);

    /// @notice Staker has been minted before public mode
    /// @dev To access pre minted info, use getter function.
    /// @param staker staker
    /// @param amount mint amount
    event PreMinted(address indexed staker, uint256 amount);

    /// @notice Salesconfig has been updated
    event SalesConfigUpdated();

    Maz private maz;
    
    mapping(address => uint256) public exchangeRates;

    /// @notice Sales states and configuration
    /// @dev Uses 3 storage slots
    struct SalesConfiguration {
        /// @dev uint256 type allows for dates into 292 billion years
        /// @notice Public stake start timestamp
        uint256 publicStakeStart;
        /// @notice Public stake end timestamp
        uint256 publicStakeEnd;
        /// @notice preStake start timestamp
        /// @dev new storage slot
        uint256 preStakeStart;
        /// @notice preStake end timestamp
        uint256 preStakeEnd;
    }

    /// @notice Sales configuration
    SalesConfiguration public salesConfig;

    constructor ( 
        address _maz,
        SalesConfiguration memory _salesConfig
    ) {
        maz = Maz(_maz);
        salesConfig = _salesConfig;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /// @notice stake mint for public
    function mintPublicStake(address staker, uint256 amount) external onlyPublicStakeActive {
        maz.stakerMint(staker, amount);
        emit PublicMinted(staker, amount);
    }
    
    /// @notice stake mint for presale
    function mintPreStake(address staker, uint256 amount) external onlyPreStakeActive {
        maz.stakerMint(staker, amount);
        emit PreMinted(staker, amount);
    }

    /// @notice set exchange rate of new token
    function setNewExchangeRate(
        address _address,
        uint256 _rate
    ) external onlyAdmin {
        exchangeRates[_address] = _rate;
        emit ExchangeRateCreated(_msgSender(), _rate);
    }

    /// @notice update exchange rate of registered token
    function updateExchangeRate(
        address _address,
        uint256 _rate
    ) external onlyAdmin canUpdateRate(_address) {
        exchangeRates[_address] = _rate;
        emit ExchangeRateUpdated(_msgSender(), _rate);
    }

    function updateSalesConfig ( 
        SalesConfiguration memory _salesConfig
    ) external onlyAdmin {
        salesConfig = _salesConfig;
        emit SalesConfigUpdated();
    }

    /// @notice time between start - end
    function _publicStakeActive() internal view returns (bool) {
        return
            salesConfig.publicStakeStart <= block.timestamp &&
            salesConfig.publicStakeEnd > block.timestamp;
    }

    /// @notice time between preStakeStart - preStakeEnd
    function _preStakeActive() internal view returns (bool) {
        return
            salesConfig.preStakeStart <= block.timestamp &&
            salesConfig.preStakeEnd > block.timestamp;
    }

    /////////////////////////////////////////////////
    /// MODIFIERS
    /////////////////////////////////////////////////

    /// @notice Only allow for users with admin access
    modifier onlyAdmin() {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            revert Access_OnlyAdmin();
        }

        _;
    }

    /// @notice Only update about added token
    modifier canUpdateRate(address _address) {
        if (exchangeRates[_address] == 0) {
            revert Not_CreatedYet();
        }

        _;
    }

    /// @notice Public sale active
    modifier onlyPublicStakeActive() {
        if (!_publicStakeActive()) {
            revert Stake_Inactive();
        }

        _;
    }

    /// @notice Presale active
    modifier onlyPreStakeActive() {
        if (!_preStakeActive()) {
            revert PreStake_Inactive();
        }

        _;
    }
}
