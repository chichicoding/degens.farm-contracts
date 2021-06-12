import pytest
import logging
import time
from brownie import Wei, reverts
LOGGER = logging.getLogger(__name__)

def test_BagsSale_buyBag_small_ether_amount_fail(accounts, sale, bagsERC20):
    price = sale.nextBagPrice()
    logging.info('price before= {}'.format(price))
    logging.info('ether= {}'.format(str(int(price/10))))
    with reverts("Need more ether!"):
        sale.buyBag({'from':accounts[1], 'value': str(int(price/10))+' wei' })
    with reverts("Need more ether!"):
        sale.buyBag({'from':accounts[1], 'value': 0 }) # bags for free?
    logging.info('after revert totalSupply {}'.format(bagsERC20.totalSupply()))
    price = sale.nextBagPrice()
    logging.info('price after= {}'.format(price))
    logging.info('contract_ethers= {}'.format(sale.balance()))
    logging.info('contract_weiRaised= {}'.format(sale.weiRaised()))
    assert bagsERC20.totalSupply() == 0
    assert bagsERC20.balanceOf(accounts[1]) == 0
    assert sale.balance() == 0
    assert sale.weiRaised() == 0

    
'''def test_BagsSale_buyBag_limit_11_bags_fail(accounts, sale, bagsERC20):
    price = sale.nextBagPrice()
    logging.info('price before= {}'.format(price))
    sale.buyBag(int(price*11), {'from':accounts[1], 'value': str(int(price*11))+' wei' })
    logging.info('after revert totalSupply {}'.format(bagsERC20.totalSupply()))
    logging.info('contract_ethers= {}'.format(sale.balance()))
    logging.info('contract_weiRaised= {}'.format(sale.weiRaised()))
    assert bagsERC20.totalSupply() == 11
    assert bagsERC20.balanceOf(accounts[1]) == 0
    assert sale.balance() == 0
    assert sale.weiRaised() == 0'''

# not actual
'''def test_BagsSale_buyBag_wantPrice_more_than_percentWant_plus_10(accounts, sale, bagsERC20):
    price = sale.nextBagPrice()
    percent = sale.percentWant()
    contract_ethers = sale.balance()
    collected_wei = sale.weiRaised()
    logging.info('price before= {}'.format(price))
    logging.info('before totalSupply {}'.format(bagsERC20.totalSupply()))
    logging.info('before balance {}'.format(bagsERC20.balanceOf(accounts[1])))
    logging.info('contract_ethers_before= {}'.format(contract_ethers))
    logging.info('contract_weiRaised_before= {}'.format(collected_wei))
    my_price = int(price*(100+percent+10)/100)
    sale.buyBag(my_price, {'from':accounts[1], 'value': my_price })
    logging.info('price after= {}'.format(sale.nextBagPrice()))
    logging.info('after totalSupply {}'.format(bagsERC20.totalSupply()))
    logging.info('after balance {}'.format(bagsERC20.balanceOf(accounts[1])))
    logging.info('contract_ethers_after= {}'.format(sale.balance()))
    logging.info('contract_weiRaised_after= {}'.format(sale.weiRaised()))
    assert bagsERC20.totalSupply() == int(my_price*1e18/price)
    assert bagsERC20.balanceOf(accounts[1]) == int(my_price*1e18/price)
    #assert sale.nextBagPrice() == int(price*sale.A()/1e4)
    assert sale.balance() == my_price
    assert sale.weiRaised() == my_price


def test_BagsSale_buyBag_wantPrice_less_than_percentWant_minus_10(accounts, sale, bagsERC20):
    price = sale.nextBagPrice()
    percent = sale.percentWant()
    contract_ethers = sale.balance()
    collected_wei = sale.weiRaised()
    balance_before = bagsERC20.balanceOf(accounts[1])
    mint_amount = bagsERC20.totalSupply()
    logging.info('price before= {}'.format(price))
    logging.info('before totalSupply {}'.format(mint_amount))
    logging.info('before balance {}'.format(balance_before))
    logging.info('contract_ethers_before= {}'.format(contract_ethers))
    logging.info('contract_weiRaised_before= {}'.format(collected_wei))
    my_price = int(price*(100+percent-10)/100)
    sale.buyBag(my_price, {'from':accounts[1], 'value': price})
    logging.info('price after= {}'.format(sale.nextBagPrice()))
    logging.info('after totalSupply {}'.format(bagsERC20.totalSupply()))
    logging.info('after balance {}'.format(bagsERC20.balanceOf(accounts[1])))
    logging.info('contract_ethers_after= {}'.format(sale.balance()))
    logging.info('contract_weiRaised_after= {}'.format(sale.weiRaised()))
    assert bagsERC20.totalSupply() - 1e18 == mint_amount
    assert bagsERC20.balanceOf(accounts[1]) - 1e18 == balance_before
    #assert sale.nextBagPrice() == int(price*sale.A()/1e4)
    assert sale.balance() == contract_ethers + price
    assert sale.weiRaised() == collected_wei + price


def test_BagsSale_buyBag_wantPrice_less_than_percentWant_minus_1(accounts, sale, bagsERC20):
    price = sale.nextBagPrice()
    percent = sale.percentWant()
    contract_ethers = sale.balance()
    collected_wei = sale.weiRaised()
    balance_before = bagsERC20.balanceOf(accounts[1])
    mint_amount = bagsERC20.totalSupply()
    logging.info('price before= {}'.format(price))
    logging.info('before totalSupply {}'.format(mint_amount))
    logging.info('before balance {}'.format(balance_before))
    logging.info('contract_ethers_before= {}'.format(contract_ethers))
    logging.info('contract_weiRaised_before= {}'.format(collected_wei))
    #my_price = int(price*(100+percent-1)/100)
    my_price = sale.bagPrice()
    sale.buyBag(my_price, {'from':accounts[1], 'value': my_price})
    logging.info('price after= {}'.format(sale.nextBagPrice()))
    logging.info('after totalSupply {}'.format(bagsERC20.totalSupply()))
    logging.info('after balance {}'.format(bagsERC20.balanceOf(accounts[1])))
    logging.info('contract_ethers_after= {}'.format(sale.balance()))
    logging.info('contract_weiRaised_after= {}'.format(sale.weiRaised()))
    #assert bagsERC20.totalSupply() - 1e18 == mint_amount
    assert bagsERC20.balanceOf(accounts[1]) - 1e18 == balance_before
    #assert sale.nextBagPrice() == int(price*sale.A()/1e4)
    assert sale.balance() == contract_ethers + my_price
    assert sale.weiRaised() == collected_wei + my_price

def test_BagsSale_buyBag_wantPrice_less_than_percentWant_minus_5(accounts, sale, bagsERC20):
    price = sale.nextBagPrice()
    percent = sale.percentWant()
    contract_ethers = sale.balance()
    collected_wei = sale.weiRaised()
    balance_before = bagsERC20.balanceOf(accounts[1])
    mint_amount = bagsERC20.totalSupply()
    logging.info('price before= {}'.format(price))
    logging.info('before totalSupply {}'.format(mint_amount))
    logging.info('before balance {}'.format(balance_before))
    logging.info('contract_ethers_before= {}'.format(contract_ethers))
    logging.info('contract_weiRaised_before= {}'.format(collected_wei))
    my_price = sale.bagPrice()
    #my_price = int(price*(100+percent-5)/100)
    sale.buyBag(my_price, {'from':accounts[1], 'value': my_price})
    logging.info('price after= {}'.format(sale.nextBagPrice()))
    logging.info('after totalSupply {}'.format(bagsERC20.totalSupply()))
    logging.info('after balance {}'.format(bagsERC20.balanceOf(accounts[1])))
    logging.info('contract_ethers_after= {}'.format(sale.balance()))
    logging.info('contract_weiRaised_after= {}'.format(sale.weiRaised()))
    assert bagsERC20.totalSupply() - 1e18 == mint_amount
    assert bagsERC20.balanceOf(accounts[1]) - 1e18 == balance_before
    assert sale.nextBagPrice() <= int(price*sale.A()/1e4)
    assert sale.balance() == contract_ethers + my_price
    assert sale.weiRaised() == collected_wei + my_price'''

# no such method
'''def test_setSaleStart(accounts, sale):
    with reverts("Ownable: caller is not the owner"):
        sale.setSaleStart(1, {"from": accounts[1]})
    sale.setSaleStart(round(time.time())+100000, {"from": accounts[0]})
    with reverts("Can't by before SALE_AFTER"):
        sale.buyBag({'from':accounts[0], 'value': sale.nextBagPrice()})'''

def test_ether_withdraw(accounts, sale):
    assert sale.balance() == sale.weiRaised()
    sale.withdraw({'from':accounts[0]})
    assert sale.balance() == 0 
    accounts[0].transfer(accounts[1], accounts[0].balance() - 100e18)
    logging.info('balance acc0 after  {}'.format(accounts[0].balance()))
    logging.info('balance acc1 after  {}'.format(accounts[1].balance()))