import pytest
import logging
from brownie import Wei, reverts, chain
LOGGER = logging.getLogger(__name__)

def test_buy_many(accounts, bagsERC20, sale):
    logging.info('Bags balance before {}'.format(bagsERC20.balanceOf(accounts[0])))
    logging.info('Next price {}'.format(
        Wei(sale.nextBagPrice()).to('ether')
    ))
    i = 0
    while i < 6:
        sale.buyBag({'from':accounts[i], 'value':150*sale.nextBagPrice()})
        logging.info('Next price after sale {} in {} round, weiRaised {}'.format(
            Wei(sale.nextBagPrice()).to('ether'),
            i,
            Wei(sale.weiRaised()).to('ether'),
        ))
        i += 1

    logging.info('bagsERC20.totalSupply() {}'.format(
            Wei(bagsERC20.totalSupply()).to('ether'),
        ))
    j = 9
    while j >= 0:
        logging.info('bagsERC20.balanceOf({}) = {}'.format(
                j,
                Wei(bagsERC20.balanceOf(accounts[j])).to('ether'),
            ))
        j -= 1        
    assert bagsERC20.balanceOf(accounts[1]) > 0


def test_reveal(accounts, bagsERC20, farm):
    logging.info('MAX_ALL_NORMIES {}'.format(farm.MAX_ALL_NORMIES()))
    logging.info('allNormiesesLeft {}'.format(farm.allNormiesesLeft()))

    bagsERC20.approve(farm, 1000e18, {'from':accounts[0]});
    bagsERC20.approve(farm, 1000e18, {'from':accounts[1]});
    bagsERC20.approve(farm, 1000e18, {'from':accounts[2]});
    bagsERC20.approve(farm, 1000e18, {'from':accounts[3]});
    bagsERC20.approve(farm, 1000e18, {'from':accounts[4]});
    bagsERC20.approve(farm, 1000e18, {'from':accounts[5]});
    i = 0
    #while i < bagsERC20.totalSupply()/1e18:
    while i < 60:
        if  i < 6:
            a = i
        else:
            a = i%6
        #landCount.left + allNormiesesLeft 
        x1 = farm.allNormiesesLeft()
        x2 = farm.landCount()
        if  x1 + x2[1] > 0 :     
            farm.reveal(1, {'from':accounts[a]});
        i += 1
    
    j = farm.CREATURE_TYPE_COUNT()-1
    while j >= 0:
        logging.info('farm.getCreatureStat({}) = {}'.format(
                j,
                farm.getCreatureStat(j),
        ))
        j -= 1

    logging.info('farm.landCount() = {}'.format(farm.landCount()))

def test_inventory_supply(accounts, inventory):
    i = 0
    while i < 6:
        logging.info('inventory.inventoryProperties: {}, URI: {} , URI2: {}'.format(
           inventory.inventoryProperties(i),
           inventory.uri(i),
           inventory.uri2(i)
        ))
        i += 1

def test_users_tokens(accounts,creatures, land):
    i=0
    while i < 6:
        logging.info('acounts[{}] creatures:{}, lands:{}'.format(
            i,
            creatures.getUsersTokens(accounts[i]),
            land.getUsersTokens(accounts[i]),
        ))
        i += 1

def test_ether_withdraw(accounts, sale):
    assert sale.balance() == sale.weiRaised()
    sale.withdraw({'from':accounts[0]})
    assert sale.balance() == 0  
    i = 0
    s = 0
    while i < 6:
        s +=  accounts[i].balance()
        i += 1
    must_amount = s/6
    j = 1
    while j < 6:
        accounts[0].transfer(accounts[j], must_amount - accounts[j].balance())
        logging.info('balance acc{} after  {}'.format(j, accounts[j].balance()))
        j += 1
    logging.info('balance acc{} after  {}'.format(0, accounts[0].balance()))

def test_one_farm(accounts, creatures, land, farm):
    logging.info('1 farming for account {}-{}'.format( 0 ,accounts[0]))
    my_crtrs = creatures.getUsersTokens(accounts[0])
    logging.info('my_crtrs={}'.format(my_crtrs))
    my_lands = land.getUsersTokens(accounts[0])
    logging.info('my_lands={}'.format(my_lands))
    res = creatures.getTypeAndRarity(my_crtrs[0])
    logging.info('!!!!!!!!!!!!!!1 creatures.getTypeAndRarity({}) {}, uri={}'.format(
        my_crtrs[0],
        res,
        creatures.tokenURI(my_crtrs[0])
    ))

    for i in my_crtrs:
        is_enable_f = farm.isFarmingAllowedForCreature(i)
        logging.info('***************** farm.isFarmingAllowedForCreature({})= {}'.format(
            i,
            is_enable_f
        ))
        assert is_enable_f == True
    allowed_for_f = farm.getFarmingAllowedCreatures(accounts[0])    
    logging.info(allowed_for_f)
    assert set(my_crtrs) == set(allowed_for_f)     

    # logging.info('amulets for type ({}) {}, uri={}'.format(
    #     res[0],
    #     farm.getCreatureAmulets(0)
    # ))

    tx = farm.farmDeploy(my_crtrs[0], my_lands[0], {'from':accounts[0]})
    logging.info(tx.events)
    logging.info('Time machine running.....+168 hours...................................')
    chain.sleep(3600*168)
    chain.mine()
    logging.info('Chain time {}'.format( chain.time()))
    logging.info(land.ownerOf(my_lands[0]))
    logging.info(creatures.ownerOf(my_crtrs[0]))
    assert land.ownerOf(my_lands[0])      == farm.address
    assert creatures.ownerOf(my_crtrs[0]) == farm.address
    my_eggs = farm.getUsersTokens(accounts[0])
    logging.info('my_eggs: {}'.format(my_eggs))
    logging.info('egg={}, farmingRec= {}'.format(
        my_eggs[0],
        farm.getFarmingById(my_eggs[0])
    ))
    tx = farm.harvest(my_eggs[0], {'from':accounts[0]})
    logging.info(tx.events['Harvest'])
    logging.info(tx.events)
    logging.info('After farming egg={}, farmingRec= {}'.format(
        my_eggs[0],
        farm.getFarmingById(my_eggs[0])
    ))
    assert creatures.ownerOf(farm.getFarmingById(my_eggs[0])[0]) == accounts[0]

def test_farm_deploy(accounts, creatures,land, farm, dungERC20):
    j = 0;
    while j < 6:
        logging.info('farming for account {}-{}'.format(j,accounts[j]))
        my_crtrs = creatures.getUsersTokens(accounts[j])
        logging.info('my_crtrs={}'.format(my_crtrs))
        my_lands = land.getUsersTokens(accounts[j])
        logging.info('my_lands={}'.format(my_lands))
        i = min(len(my_crtrs), len(my_lands))
        while i > 0:
            logging.info('Land id {}, owner {}'.format(
                my_lands[i-1],
                land.ownerOf(my_lands[i-1]),
            ))

            res = creatures.getTypeAndRarity(my_crtrs[i-1])
            logging.info('!!!!!!!!!!!!!!1creatures.getTypeAndRarity({}) {}'.format(
                my_crtrs[i-1],
                res,
            ))
            crType = res[0]
            crRarity = res[1]   
            if  (crRarity == 0) :
                if  farm.creaturesBorn(crType)[3] == 0:
                    i -=1
                    continue
            if  (crRarity == 1) :
                if  farm.creaturesBorn(crType)[5] == 0:
                    i -=1
                    continue
            if  (crRarity == 2) :
                i -=1
                continue                
            #creaturesBorn
            tx = farm.farmDeploy(my_crtrs[i-1], my_lands[i-1], {'from':accounts[j]})
            logging.info(tx.events['Transfer'][0])
            logging.info('Stake Land:{}'.format(
                tx.events['Transfer'][1]
            ))
            logging.info('Stake Crea:{}'.format(
                tx.events['Transfer'][1]
            ))      
            assert land.ownerOf(my_lands[i-1])      == farm.address
            assert creatures.ownerOf(my_crtrs[i-1]) == farm.address
            i -=1
        
        logging.info('Time machine running.....+168 hours...................................')
        chain.sleep(3600*168)
        chain.mine()
        logging.info('Chain time {}'.format( chain.time()))

        my_eggs = farm.getUsersTokens(accounts[j])
        logging.info('my_eggs: {}'.format(my_eggs))
        i = len(my_eggs)
        while i > 0:
            logging.info('Before harvest, egg={}, farmingRec= {}'.format(
                my_eggs[i-1],
                farm.getFarmingById(my_eggs[i-1])
            ))
            tx = farm.harvest(my_eggs[i-1], {'from':accounts[j]})
            logging.info(tx.events['Harvest']) 
            logging.info(farm.getFarmingById(my_eggs[i-1]))
            assert creatures.ownerOf(farm.getFarmingById(my_eggs[i-1])[0]) == accounts[j]     
            i -=1
            logging.info('Time machine running.....+1 sec...')
            chain.sleep(1)
            chain.mine()
            logging.info('Chain time {}'.format( chain.time()))
        j += 1
    j = farm.CREATURE_TYPE_COUNT()-1   
    while j >= 0:
        logging.info('farm.getCreatureStat({}) = {}'.format(
                j,
                farm.getCreatureStat(j),
        ))
        j -= 1

    logging.info('farm.landCount() = {}'.format(farm.landCount()))
    #############################################
    ### Show Dung Balance stat
    #############################################    
    j = 0
    while j < 6:
        logging.info('Dung balanceOf accounts[{}]={}'.format(
            accounts[j],
            Wei(dungERC20.balanceOf(accounts[j])).to("ether")
        ))
        j += 1      

def test_farm_deploy_chads_with_inventory(accounts, creatures,land, farm, inventory, dungERC20):
    j = 0;
    while j < 6:
        logging.info('Second farming for account {}-{}'.format(j,accounts[j]))
        my_crtrs = creatures.getUsersTokens(accounts[j])
        logging.info('my_crtrs={}'.format(my_crtrs))
        my_lands = land.getUsersTokens(accounts[j])
        logging.info('my_lands={}'.format(my_lands))
        my_chads = [x for x in my_crtrs if x > 10000]
        logging.info('my_chads={}'.format(my_chads))
        #Let`s get inventory
        if j > 0:
            dungERC20.mint(accounts[j], inventory.inventoryProperties(0)[1], {'from': accounts[0]})
            dungERC20.approve(inventory.address,  dungERC20.balanceOf(accounts[j]), {'from': accounts[j]})
            tx = inventory.dungSwap(0, 1, {'from':accounts[j]})
            logging.info(tx.events)
            logging.info('Inventory item {} balance {} for accounts[{}]'.format(
                0,
                inventory.balanceOf(accounts[j], 0),
                j
            ))
            tx = inventory.setApprovalForAll(farm.address, True, {'from':accounts[j]})
            tx = farm.stakeOneTool(0,{'from':accounts[j]})
        i = min(len(my_chads), len(my_lands))
        while i > 0:
            logging.info('Chad id {}, owner {}'.format(
                my_chads[i-1],
                creatures.ownerOf(my_chads[i-1]),
            ))

            tx = creatures.getTypeAndRarity(my_chads[i-1])
            logging.info('!!!!!!!!!!!!!!1creatures.getTypeAndRarity({}) {}'.format(
                my_lands[i-1],
                tx,
            ))
            crType = tx[0]
            crRarity = tx[1]   
            if  (crRarity == 0) :
                if  farm.creaturesBorn(crType)[3] == 0:
                    i -=1
                    continue
            if  (crRarity == 1) :
                if  farm.creaturesBorn(crType)[5] == 0:
                    i -=1
                    continue
            if  (crRarity == 2) :
                i -=1
                continue        
            tx = farm.farmDeploy(my_chads[i-1], my_lands[i-1], {'from':accounts[j]})
            logging.info(tx.events['Transfer'][0])
            assert land.ownerOf(my_lands[i-1])      == farm.address
            assert creatures.ownerOf(my_chads[i-1]) == farm.address
            i -=1
        logging.info('Time machine running.....+168 hours...................................')
        chain.sleep(3600*168)
        chain.mine()
        logging.info('Chain time {}'.format( chain.time()))

        my_eggs = farm.getUsersTokens(accounts[j])
        logging.info('my_eggs: {}'.format(my_eggs))
        i = len(my_eggs)
        while i > 0:
            logging.info('egg={}, farmingRec= {}'.format(
                my_eggs[i-1],
                farm.getFarmingById(my_eggs[i-1])
            ))
            tx = farm.harvest(my_eggs[i-1], {'from':accounts[j]})
            logging.info(tx.events['Harvest']) 
            logging.info(farm.getFarmingById(my_eggs[i-1]))
            assert creatures.ownerOf(farm.getFarmingById(my_eggs[i-1])[0]) == accounts[j]     
            i -=1
        j += 1          
    #############################################
    ### Show Creature stat
    ############################################# 
    j = farm.CREATURE_TYPE_COUNT()-1    
    while j >= 0:
        logging.info('farm.getCreatureStat({}) = {}'.format(
                j,
                farm.getCreatureStat(j),
        ))
        j -= 1
    #############################################
    ### Show Dung Balance stat
    #############################################    
    j = 0
    while j < 6:
        logging.info('Dung balanceOf accounts[{}]={}'.format(
            accounts[j],
            Wei(dungERC20.balanceOf(accounts[j])).to("ether")
        ))
        j += 1    
