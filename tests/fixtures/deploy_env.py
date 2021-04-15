import pytest


@pytest.fixture(scope="module")
def bagsERC20(accounts, Bags):
    bags = accounts[0].deploy(Bags, 900e18)
    yield bags

@pytest.fixture(scope="module")
def sale(accounts, BagSale, bagsERC20):
    sale = accounts[0].deploy(BagSale,bagsERC20.address)
    bagsERC20.transferOwnership(sale.address)
    yield sale

