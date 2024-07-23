const StakingMinter = artifacts.require('./StakingMinter.sol') ;
const Maz = artifacts.require('./Maz.sol') ;
const { assert } = require('chai');
const { keccak256, toUtf8Bytes } = require('ethers/lib/utils');
const { BigNumber } = require('ethers');

require('chai')
    .use(require('chai-as-promised'))
    .should() ;

contract('Maz Contract', async () => {
    let maz ;
    let stakingMinter ;
    const ONE_DAY_MILLISECONDS = 24 * 60 * 60 * 1000 ;
    const presalePeriod = 20 ;
    const presaleStart = Date.now() ;
    const presaleEnd = presaleStart + presalePeriod * ONE_DAY_MILLISECONDS ;
    const publicStart = presaleEnd ;
    const publicEnd = publicStart + 365 * ONE_DAY_MILLISECONDS ;
    const USDT_ADDRESS = "0x7169D38820dfd117C3FA1f22a697dBA58d90BA06";

    const minterSignature = keccak256(toUtf8Bytes("MINTER_ROLE"));

    before(async () => {
        maz = await Maz.deployed() ;
        stakingMinter = await StakingMinter.deployed([
            maz.address, 
            {
              publicStakeStart: BigNumber.from(presaleStart.toString()),
              publicStakeEnd: BigNumber.from(presaleEnd.toString()),
              preStakeStart: BigNumber.from(publicStart.toString()),
              preStakeEnd: BigNumber.from(publicEnd.toString())
            }
        ]) ;
    });

    it('should be same as with stakingMinter contract address' , async() => {
        maz.setStakeMinter(stakingMinter.address);
        const stakeMinter = await maz.getStakeMinter();
        assert(
            stakingMinter.address,
            stakeMinter,
            "stakeMinter is not equal with deployed stakingMinter contract address"
        )
    });

    it('stakingMinter should have minter role' , async() => {
        const hasMinterRole = maz.hasRole(minterSignature, stakingMinter.address);
        assert(
            hasMinterRole,
            true,
            "stakingMinter don't have minter role"
        )
    });

    it('salesconfig should be equal with conts.' , async() => {
        const salesConfig = await stakingMinter.salesConfig();
        const publicStakeStart = salesConfig.publicStakeStart.toString();
        const publicStakeEnd = salesConfig.publicStakeEnd.toString();
        const preStakeStart = salesConfig.preStakeStart.toString();
        const preStakeEnd = salesConfig.preStakeEnd.toString();

        assert(
            [publicStakeStart, publicStakeEnd, preStakeStart, preStakeEnd],
            [publicStart, publicEnd, presaleStart, presaleEnd],
            "Salesconfig is not equal with initial consts."
        )
    });

    it('should set exhange rate of USDT.' , async() => {
        const exchangeRate = 1;
        const { logs } = await stakingMinter.setNewExchangeRate(USDT_ADDRESS, BigNumber.from(exchangeRate));
        const event = logs.filter(log => log.event === "ExchangeRateCreated");
        assert(
            event.length >= 1,
            true,
            "exchange rate of USD is not setup."
        )
    });

    it('exchangeRate of USDT should be 1' , async() => {
        const exchangeRateOfUSDT = await stakingMinter.exchangeRates(USDT_ADDRESS);
        assert(
            exchangeRateOfUSDT.toString(),
            "1",
            "exchangeRate of USDT is not 1."
        )
    });

    it('should update exhange rate of USDT as 2.' , async() => {
        const newExchangeRate = 2;
        const { logs } = await stakingMinter.updateExchangeRate(USDT_ADDRESS, BigNumber.from(newExchangeRate));
        const event = logs.filter(log => log.event === "ExchangeRateUpdated");
        assert(
            event.length >= 1,
            true,
            "exchange rate of USD is not updated."
        )
    });

    it('exchangeRate of USDT should be 2 after updating rate' , async() => {
        const exchangeRateOfUSDT = await stakingMinter.exchangeRates(USDT_ADDRESS);
        assert(
            exchangeRateOfUSDT.toString(),
            "2",
            "exchangeRate of USDT is not 2 after updating rate."
        )
    });
});
