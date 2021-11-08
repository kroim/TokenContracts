// SPDX-License-Identifier: MIT
/**
15% total tax

Using chainlinks VRF (verified random function) the token will have an hourly and a daily lottery, 
based off the volume of the token. This will account for 1% of the tax, .25% going to the hourly draw, 
and .75% going to the daily winner.

The NFT contract I want to make it so there are 6 Levels of reflection amplifiers.

The first level would be a .5% increase in reflections
The second level would be a 1% increase in reflections
The third level would be a 1.5% increase in reflections
The fourth level would be a 2% increase in reflections
The fifth level would be a 3% increase in reflections
The sixth level would be people own 1 of each of the previous levels, a set of NFT's. 
People with the full set will be given 5% extra reflections.

The base level of reflections would be 5% and I wanted these converted to USDT. 

1% auto-liquidity

The remaining tax would be sent to a mkt/project wallet which I want auto-converted to USDT.
(Which would mean for people who dont hold NFTs, this would be 8%, and for people with the full set, it would be 3%)

total supply: 1 billion
 */
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// PancakeRouter Interface
interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

library Utils {
    using SafeMath for uint256;

    function random(uint256 from, uint256 to, uint256 salty) private view returns (uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp + block.difficulty +
                    ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
                    block.gaslimit +
                    ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
                    block.number +
                    salty
                )
            )
        );
        return seed.mod(to - from) + from;
    }

    function isLotteryWon(uint256 salty, uint256 winningDoubleRewardPercentage) private view returns (bool) {
        uint256 luckyNumber = random(0, 100, salty);
        uint256 winPercentage = winningDoubleRewardPercentage;
        return luckyNumber <= winPercentage;
    }

    function calculateBNBReward(
        uint256 _tTotal,
        uint256 currentBalance,
        uint256 currentBNBPool,
        uint256 winningDoubleRewardPercentage,
        uint256 totalSupply,
        address ofAddress
    ) public view returns (uint256) {
        uint256 bnbPool = currentBNBPool;

        // calculate reward to send
        bool isLotteryWonOnClaim = isLotteryWon(currentBalance, winningDoubleRewardPercentage);
        uint256 multiplier = 100;

        if (isLotteryWonOnClaim) {
            multiplier = random(150, 200, currentBalance);
        }

        // now calculate reward
        uint256 reward = bnbPool.mul(multiplier).mul(currentBalance).div(100).div(totalSupply);

        return reward;
    }

    function calculateTopUpClaim(
        uint256 currentRecipientBalance,
        uint256 basedRewardCycleBlock,
        uint256 threshHoldTopUpRate,
        uint256 amount
    ) public returns (uint256) {
        if (currentRecipientBalance == 0) {
            return block.timestamp + basedRewardCycleBlock;
        }
        else {
            uint256 rate = amount.mul(100).div(currentRecipientBalance);

            if (uint256(rate) >= threshHoldTopUpRate) {
                uint256 incurCycleBlock = basedRewardCycleBlock.mul(uint256(rate)).div(100);

                if (incurCycleBlock >= basedRewardCycleBlock) {
                    incurCycleBlock = basedRewardCycleBlock;
                }

                return incurCycleBlock;
            }

            return 0;
        }
    }

    function swapTokensForUSDT(
        address routerAddress,
        uint256 tokenAmount,
        address usdtAddress
    ) public {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdtAddress);

        // make the swap
        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of usdt
            path,
            address(this),
            block.timestamp
        );
    }

    function swapUSDTForTokens(
        address routerAddress,
        address recipient,
        uint256 usdtAmount,
        address usdtAddress
    ) public {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(usdtAddress);
        path[1] = address(this);

        // make the swap
        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtAmount,
            0, // accept any amount of usdt
            path,
            address(recipient),
            block.timestamp + 360
        );
    }

    function addLiquidity(
        address routerAddress,
        address owner,
        uint256 tokenAmount,
        address usdtAddress,
        uint256 usdtAmount
    ) internal {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);
        // add the liquidity
        pancakeRouter.addLiquidity(
            address(this),
            address(usdtAddress),
            tokenAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
            block.timestamp + 360
        );
    }
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}

interface IBCNFT {
    function checkAccountLevel(address _account) external view returns (uint256);
    function checkNFTHolder(address _account) external view returns (bool);
    function getHolders() external view returns (address[] memory);
}

contract BCToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    address[] private _excluded;
    string private _name = "BCToken";
    string private _symbol = "BCTN";
    uint8 private _decimals = 18;

    IPancakeRouter02 public immutable pancakeRouter;
    address public immutable pancakePair;
    address public usdtAddress;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000 * 10**6 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 private _tLiquidityAmount = 0;

    uint256 public _rewardFee = 500;
    uint256 private _previousRewardFee = _rewardFee;
    uint256 public _taxFee = 800;
    uint256 private _previousTaxFee = _taxFee;
    uint256 public _taxNFTFee = 300;
    uint256 private _previousTaxNFTFee = _taxNFTFee;
    // reflection by nft levels
    uint256 public level1Fee = 50;
    uint256 public level2Fee = 100;
    uint256 public level3Fee = 150;
    uint256 public level4Fee = 200;
    uint256 public level5Fee = 300;
    uint256 public level6Fee = 500;
    uint256 private _prevLevel1Fee = level1Fee;
    uint256 private _prevLevel2Fee = level2Fee;
    uint256 private _prevLevel3Fee = level3Fee;
    uint256 private _prevLevel4Fee = level4Fee;
    uint256 private _prevLevel5Fee = level5Fee;
    uint256 private _prevLevel6Fee = level6Fee;
    // 0.001% max tx amount will trigger swap and add liquidity
    uint256 private _minTokenBalaceToLiquidity = _tTotal.mul(1).div(1000).div(100);
    uint256 public autoLiquidity = 100;
    uint256 private _prevAutoLiquidity = autoLiquidity;
    uint256 public lotteryHourly = 25;
    uint256 public lotteryDaily = 75;
    uint256 public _maxTxAmount = 20 * 10**6 * 10**_decimals;
    address private _charityAddress = 0xBDA2e26669eb6dB2A460A9018b16495bcccF6f0a;
    address private _charityWallet;

    uint256 public lotteryLimitAmount = 10**6 * 10**_decimals;  // 0.001%
    uint256 public charityMinimum = 10**4 * 10**_decimals;
    bool public pausedLottery = false;
    
    address public dailyAddress;
    address public hourlyAddress;
    IBCNFT public immutable iBCNFT;

    event SwapAndLiquify(uint256 tokensSwapped, uint256 usdtReceived, uint256 tokensIntoLiqudity);

    constructor(address _nftAddress, address payable routerAddress, address _usdtAddress) {
        iBCNFT = IBCNFT(_nftAddress);
        IPancakeRouter02 _pancakeRouter = IPancakeRouter02(routerAddress);
        usdtAddress = _usdtAddress;
        pancakePair = IPancakeFactory(_pancakeRouter.factory()).createPair(address(this), address(usdtAddress));
        pancakeRouter = _pancakeRouter;

        _rOwned[_msgSender()] = _rTotal;
        _charityWallet = _charityAddress;
        _tOwned[_charityWallet] = 0;
        _rOwned[_charityWallet] = 0;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub(amount,"ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount, address _account) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,,,) = _getValues(tAmount, _account);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee, address _account) public view returns (uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,,) = _getValues(tAmount, _account);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,,) = _getValues(tAmount, _account);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (
            uint256 rAmount, 
            uint256 rTransferAmount, 
            uint256 rRewardFee,
            uint256 tTransferAmount, 
            uint256 tRewardFee, 
            uint256 tBurnFee, 
            uint256 tTaxFee) = _getValues(tAmount, recipient);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tBurnFee);
        _takeCharity(tTaxFee);
        _reflectFee(rRewardFee, tRewardFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
        _taxFee = taxFee;
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(10**2);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount, address _account) private view 
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) 
    {
        (uint256 tTransferAmount, uint256 tRewardFee, uint256 tBurnFee, uint256 tTaxFee) = _getTValues(tAmount, _account);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rRewardFee) =
            _getRValues(tAmount, tRewardFee, tBurnFee, tTaxFee, _getRate());
        return (rAmount, rTransferAmount, rRewardFee, tTransferAmount, tRewardFee, tBurnFee, tTaxFee);
    }

    function _getTValues(uint256 tAmount, address _account) private view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tRewardFee = calculateRewardFee(tAmount);
        uint256 tBurnFee = calculateLiquidityFee(tAmount);
        uint256 tTaxFee = calculateTaxFee(tAmount, _account);
        uint256 tTransferAmount = tAmount.sub(tRewardFee).sub(tBurnFee).sub(tTaxFee);
        return (tTransferAmount, tRewardFee, tBurnFee, tTaxFee);
    }

    function _getRValues(uint256 tAmount, uint256 tRewardFee, uint256 tBurnFee, uint256 tTaxFee, uint256 currentRate) private pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rRewardFee = tRewardFee.mul(currentRate);
        uint256 rBurnFee = tBurnFee.mul(currentRate);
        uint256 rTaxFee = tTaxFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rRewardFee).sub(rBurnFee).sub(rTaxFee);
        return (rAmount, rTransferAmount, rRewardFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function calculateRewardFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_rewardFee).div(10**4);
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(autoLiquidity).div(10**4);
    }

    function calculateTaxFee(uint256 _amount, address _account) private view returns (uint256) {
        /**
        tax by NFT holds
        if ("this user has nft" == "") return _amount.mul(_taxNFTFee).div(10**4);
        else return _amount.mul(_taxFee).div(10**4);
         */
        if (iBCNFT.checkNFTHolder(_account)) {
            return _amount.mul(_taxNFTFee).div(10**4);
        } else {
            return _amount.mul(_taxFee).div(10**4);
        }
    }

    function removeAllFee() private {
        if (_taxFee == 0) return;
        _previousRewardFee = _rewardFee;
        _previousTaxFee = _taxFee;
        _previousTaxNFTFee = _taxNFTFee;
        _prevLevel1Fee = level1Fee;
        _prevLevel2Fee = level2Fee;
        _prevLevel3Fee = level3Fee;
        _prevLevel4Fee = level4Fee;
        _prevLevel5Fee = level5Fee;
        _prevLevel6Fee = level6Fee;
        _prevAutoLiquidity = autoLiquidity;

        _rewardFee = 0;
        _taxFee = 0;
        _taxNFTFee = 0;
        level1Fee = 0;
        level2Fee = 0;
        level3Fee = 0;
        level4Fee = 0;
        level5Fee = 0;
        level6Fee = 0;
        autoLiquidity = 0;
    }

    function restoreAllFee() private {
        _rewardFee = _previousRewardFee;
        _taxFee = _previousTaxFee;
        _taxNFTFee = _previousTaxNFTFee;
        level1Fee = _prevLevel1Fee;
        level2Fee = _prevLevel2Fee;
        level3Fee = _prevLevel3Fee;
        level4Fee = _prevLevel4Fee;
        level5Fee = _prevLevel5Fee;
        level6Fee = _prevLevel6Fee;
        autoLiquidity = _prevAutoLiquidity;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (from != owner() && to != owner())
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

        // swap and liquify
        swapAndLiquify(from, to);

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        //transfer amount, it will take reward, burn, tax fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if (!takeFee) removeAllFee();

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if (!takeFee) restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (
            uint256 rAmount, 
            uint256 rTransferAmount, 
            uint256 rRewardFee,
            uint256 tTransferAmount, 
            uint256 tRewardFee, 
            uint256 tBurnFee, 
            uint256 tTaxFee) = _getValues(tAmount, recipient);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tBurnFee);
        _takeCharity(tTaxFee);
        _reflectFee(rRewardFee, tRewardFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (
            uint256 rAmount, 
            uint256 rTransferAmount, 
            uint256 rRewardFee,
            uint256 tTransferAmount, 
            uint256 tRewardFee,
            uint256 tBurnFee, 
            uint256 tTaxFee) = _getValues(tAmount, recipient);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tBurnFee);
        _takeCharity(tTaxFee);
        _reflectFee(rRewardFee, tRewardFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (
            uint256 rAmount, 
            uint256 rTransferAmount, 
            uint256 rRewardFee,
            uint256 tTransferAmount, 
            uint256 tRewardFee, 
            uint256 tBurnFee, 
            uint256 tTaxFee) = _getValues(tAmount, recipient);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tBurnFee);
        _takeCharity(tTaxFee);
        _reflectFee(rRewardFee, tRewardFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _takeLiquidity(uint256 tBurnFee) private {
        _tLiquidityAmount = _tLiquidityAmount.add(tBurnFee);
        if (_tLiquidityAmount >= _minTokenBalaceToLiquidity) {
            // add liquidity
            autoSwapAndLiquidity(_tLiquidityAmount);
            _tLiquidityAmount = 0;
        }
    }

    function _takeCharity(uint256 tCharity) private {
        uint256 currentRate = _getRate();
        uint256 rCharity = tCharity.mul(currentRate);
        _rOwned[_charityWallet] = _rOwned[_charityWallet].add(rCharity);
        uint256 initialBalance = IERC20(usdtAddress).balanceOf(address(this));
        if (_rOwned[_charityWallet] >= charityMinimum) {
            // add liquidity
            Utils.swapTokensForUSDT(address(pancakeRouter), _rOwned[_charityWallet], usdtAddress);
            uint256 deltaBalance = IERC20(usdtAddress).balanceOf(address(this)).sub(initialBalance);
            _rOwned[_charityWallet] = 0;
            IERC20(usdtAddress).transfer(_charityWallet, deltaBalance);
        }
    }

    function setLotteryAddress(address _dailyAddress, address _hourlyAddress) external onlyOwner {
        dailyAddress = _dailyAddress;
        hourlyAddress = _hourlyAddress;
    }

    function setLotteryState() external onlyOwner {
        pausedLottery = !pausedLottery;
    }

    function lotteryTransfer(address _winner) external {
        require(!pausedLottery, "Lottery is paused.");
        require(msg.sender == dailyAddress || msg.sender == hourlyAddress, "Can only be called by lottery contract");
        require(balanceOf(_winner) >= lotteryLimitAmount, "Can not be a winner from the efficient balance");
        uint256 lottery = 0;
        uint256 currentBalance = balanceOf(address(this));
        uint256 level = iBCNFT.checkAccountLevel(_winner);
        if (level == 0) return;
        uint256 levelPercent = level1Fee;
        if (level == 2) levelPercent = level2Fee;
        if (level == 3) levelPercent = level3Fee;
        if (level == 4) levelPercent = level4Fee;
        if (level == 5) levelPercent = level5Fee;
        if (level == 6) levelPercent = level6Fee;
        uint256 lotteryPercent = lotteryHourly;
        if (_msgSender() == dailyAddress) lotteryPercent = lotteryDaily;
        lottery = currentBalance.mul(levelPercent).mul(lotteryPercent).div(10**8);
        _tokenTransfer(address(this), _winner, lottery, true);
    }

    function setLotteryLimit(uint256 _lotteryLimit) external onlyOwner {
        lotteryLimitAmount = _lotteryLimit;
    }

    function swapAndLiquify(address from, address to) private {
        uint256 contractTokenBalance = balanceOf(address(this));
        if (contractTokenBalance >= _maxTxAmount) {
            contractTokenBalance = _maxTxAmount;
        }
        bool shouldSell = contractTokenBalance >= _minTokenBalaceToLiquidity;
        if (
            shouldSell && 
            from != pancakePair && 
            !(from == address(this) && to == address(pancakePair)) // swap 1 time
        ) {
            contractTokenBalance = _minTokenBalaceToLiquidity;
            // add liquidity
            autoSwapAndLiquidity(contractTokenBalance);
        }
    }

    function autoSwapAndLiquidity(uint256 _tokenAmount) internal {
        // split the contract balance into 3 pieces
        uint256 pooledUSDT = _tokenAmount.div(2);
        uint256 piece = _tokenAmount.sub(pooledUSDT).div(2);
        uint256 otherPiece = _tokenAmount.sub(piece);
        uint256 tokenAmountToBeSwapped = pooledUSDT.add(piece);
        uint256 initialBalance = IERC20(usdtAddress).balanceOf(address(this));

        Utils.swapTokensForUSDT(address(pancakeRouter), tokenAmountToBeSwapped, usdtAddress);
        uint256 deltaBalance = IERC20(usdtAddress).balanceOf(address(this)).sub(initialBalance);
        uint256 usdtToBeAddedToLiquidity = deltaBalance.div(3);
        // add liquidity to pancake
        Utils.addLiquidity(address(pancakeRouter), owner(), otherPiece, usdtAddress, usdtToBeAddedToLiquidity);
        emit SwapAndLiquify(piece, deltaBalance, otherPiece);
    }

    function selectWinner(uint256 seed) external view returns (address) {
        require(!pausedLottery, "Lottery is paused.");
        require(msg.sender == dailyAddress || msg.sender == hourlyAddress, "Can only be called by lottery contract");
        address[] memory holders = iBCNFT.getHolders();
        require(holders.length > 1, "Holders are not enough to run lottery");
        uint256 mod = holders.length - 1;
        uint256 rndNum = uint256(keccak256(abi.encode(block.timestamp, block.difficulty, block.coinbase, blockhash(block.number + 1), seed, block.number))).mod(mod);
        return holders[rndNum];
    }
}