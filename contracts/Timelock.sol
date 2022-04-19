// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TimeLock is ERC20 {
    using SafeMath for uint256;
    
    uint256 private _totalSupply = 1000;
    uint256 public startDate;
    uint256 public endDate;
    uint256 public limitAmount = 100;
    uint256 public currentAmount = 0;
    
    constructor() ERC20("TimeLock", "TimeLock") {
        startDate = block.timestamp;
        endDate = startDate + 30 days;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function mint(address _to, uint256 _amount) public {
        if (block.timestamp > endDate) {
            startDate = block.timestamp;
            endDate = startDate + 30 days;
            currentAmount = 0;
        }
        require(currentAmount + _amount <= limitAmount, "Unable mint token!");
        currentAmount += _amount;
        _mint(_to, _amount);
    }
}