// Original: https://github.com/aave/aave-protocol/blob/master/contracts/flashloan/base/FlashLoanReceiverBase.sol
pragma solidity ^0.5.0;

import "./math/SafeMath.sol";
import "./utils/IERC20.sol";
import "./utils/SafeERC20.sol";
import "./EthAddressLib.sol";
import "./IFlashLoanReceiver.sol";
import "./ILendingPoolAddressesProvider.sol";

contract FlashLoanReceiverBase is IFlashLoanReceiver {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // TODO: Set here the address of the Aave protocol addresses provider.
    // See https://developers.aave.com/#the-lendingpooladdressesprovider. This address should not change once deployed.
    ILendingPoolAddressesProvider public constant addressesProvider = ILendingPoolAddressesProvider(address(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8));

    function () external payable { }

    function transferFundsBackToPoolInternal(address _reserve, uint256 _amount) internal {
        address payable core = addressesProvider.getLendingPoolCore();
        transferInternal(core, _reserve, _amount);
    }

    function transferInternal(address payable _destination, address _reserve, uint256 _amount) internal {
        if(_reserve == EthAddressLib.ethAddress()) {
            //solium-disable-next-line
            _destination.call.value(_amount)("");
            return;
        }
        IERC20(_reserve).safeTransfer(_destination, _amount);
    }

    function getBalanceInternal(address _target, address _reserve) internal view returns(uint256) {
        if(_reserve == EthAddressLib.ethAddress()) {
            return _target.balance;
        }
        return IERC20(_reserve).balanceOf(_target);
    }
}
