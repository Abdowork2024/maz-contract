const Maz = artifacts.require("Maz");
const StakingMinter = artifacts.require("StakingMinter") ;
const { BigNumber } = require('ethers');

module.exports = async function (deployer) {
  const ONE_DAY_MILLISECONDS = 24 * 60 * 60 * 1000 ;
  const presalePeriod = 20 ;
  const presaleStart = Date.now() ;
  const presaleEnd = presaleStart + presalePeriod * ONE_DAY_MILLISECONDS ;
  const publicStart = presaleEnd ;
  const publicEnd = publicStart + 365 * ONE_DAY_MILLISECONDS ;

  await deployer.deploy(Maz);
  const maz = await Maz.deployed() ;

  await deployer.deploy(
    StakingMinter,
    maz.address, 
    {
      publicStakeStart: BigNumber.from(presaleStart.toString()),
      publicStakeEnd: BigNumber.from(presaleEnd.toString()),
      preStakeStart: BigNumber.from(publicStart.toString()),
      preStakeEnd: BigNumber.from(publicEnd.toString())
    }
  );

  const stakingMinter =  await StakingMinter.deployed() ;

  const stakingMinterAddress = stakingMinter.address ;

  console.log("Maz Contract: ", maz.address) ;
  console.log("Staking Minter Contract:", stakingMinterAddress);
}; 