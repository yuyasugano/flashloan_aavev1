pragma solidity ^0.5.0;

import "./aave1/FlashLoanReceiverBase.sol";
import "./aave1/ILendingPoolAddressesProvider.sol";
import "./aave1/ILendingPool.sol";

contract Flashloan is FlashLoanReceiverBase {

    function flashloan(address _asset, uint256 _amount) external
    {
        bytes memory data = "";
        ILendingPool lendingPool = ILendingPool(
            addressesProvider.getLendingPool()
        );
        // invoke a flashloan and receive a loan on this contract itself
        lendingPool.flashLoan(address(this), _asset, _amount, data);
    }

    function executeOperation(
        address _reserve,
        uint256 _amount,
        uint256 _fee,
        bytes calldata _params
    )
        external
    {
        require(
            _amount <= getBalanceInternal(address(this), _reserve),
            "Invalid balance, was the flashload successful?"
        );

        // arbitrage, refinance loan, swap collaterals
        // empty flashloan does nothing but transfer the funds back with fee 

        // return the funds back
        uint256 totalDebt = _amount.add(_fee);
        transferFundsBackToPoolInternal(_reserve, totalDebt);
    }
}

