// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./IPancakeRouter02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract EldaTrader is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    IPancakeRouter02 private _pancakeRouter;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address defaultAdmin,
        address pauser,
        address upgrader,
        address routerAddress
    ) public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(PAUSER_ROLE, pauser);
        _grantRole(UPGRADER_ROLE, upgrader);
        _pancakeRouter = IPancakeRouter02(routerAddress);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    function setPancakeRouter(
        address _routerAddress
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pancakeRouter = IPancakeRouter02(_routerAddress);
    }

    function trade(address token, address busdToken) external payable {
        address[] memory pathELDAToBUSD = new address[](2);
        pathELDAToBUSD[0] = token;
        pathELDAToBUSD[1] = busdToken;
        uint256 amountInELDA = IERC20(token).balanceOf(address(this));
        IERC20(token).approve(address(_pancakeRouter), amountInELDA);
        _pancakeRouter.swapExactTokensForTokens(
            amountInELDA,
            0,
            pathELDAToBUSD,
            address(this),
            block.timestamp + 1000
        );

        address[] memory pathBUSDToBNB = new address[](2);
        pathBUSDToBNB[0] = busdToken;
        pathBUSDToBNB[1] = _pancakeRouter.WETH();
        uint256 amountOutMinBNB = 0;
        IERC20(busdToken).approve(
            address(_pancakeRouter),
            IERC20(busdToken).balanceOf(address(this))
        );
        _pancakeRouter.swapExactTokensForETH(
            IERC20(busdToken).balanceOf(address(this)),
            amountOutMinBNB,
            pathBUSDToBNB,
            address(this),
            block.timestamp + 1000
        );

        address[] memory pathBNBToBUSD = new address[](2);
        pathBNBToBUSD[0] = _pancakeRouter.WETH();
        pathBNBToBUSD[1] = busdToken;
        uint256 amountOutMinBUSD = 0;
        _pancakeRouter.swapExactETHForTokens{value: address(this).balance}(
            amountOutMinBUSD,
            pathBNBToBUSD,
            address(this),
            block.timestamp + 1000
        );

        uint256 amountInBUSD = IERC20(busdToken).balanceOf(address(this));
        address[] memory pathBUSDToELDA = new address[](2);
        pathBUSDToELDA[0] = busdToken;
        pathBUSDToELDA[1] = token;
        uint256 amountOutMinELDA = 0;
        IERC20(busdToken).approve(address(_pancakeRouter), amountInBUSD);
        _pancakeRouter.swapExactTokensForTokens(
            amountInBUSD,
            amountOutMinELDA,
            pathBUSDToELDA,
            address(this),
            block.timestamp + 1000
        );
    }

    function withdrawTokens(
        address _token,
        uint256 _amount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC20(_token).transfer(msg.sender, _amount);
    }

    function withdrawBNB() external onlyRole(DEFAULT_ADMIN_ROLE) {
        payable(_msgSender()).transfer(address(this).balance);
    }

    receive() external payable {}
}
