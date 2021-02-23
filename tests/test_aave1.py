import pytest
import click

# isolation fixture for each function, takes a snapshot of the chain
@pytest.fixture(scope='function', autouse=True)
def isolation(fn_isolation):
    pass

def test_flashloan_aave1(accounts, interface, chain, Flashloan):
    # prepare accounts
    user = accounts[0]
    amount = 10 * 1e18
    flashloan = Flashloan.deploy({'from': user})
    user.transfer(flashloan.address, "1 ether", gas_price=0)
    beforeBalance = flashloan.balance()

    tx = flashloan.flashloan(
        "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE",
        amount
    )
    tx.info()
    afterBalance = flashloan.balance()
    print(click.style(f'remained eth in wei: {afterBalance}', fg='green', bold=True))
    # Flashloan fee is 0.09% of the borrowed amount
    assert afterBalance == beforeBalance - 9000000000000000, 'Aave V1 Flashloan did not run correctly'

