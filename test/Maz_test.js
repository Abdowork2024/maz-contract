const Maz = artifacts.require('./Maz.sol') ;
const { keccak256, toUtf8Bytes } = require('ethers/lib/utils');

require('chai')
    .use(require('chai-as-promised'))
    .should() ;

contract('Maz Contract', async (accounts) => {
    let maz ;
    const deployer = accounts[0];
    const minterSignature = keccak256(toUtf8Bytes("MINTER_ROLE"));

    before(async () => {
        maz = await Maz.deployed() ;
    });

    it('should have minter role in the first account' , async() => {
        const role = await maz.hasRole(minterSignature, deployer);
        assert.equal(
            role,
            true,
            "First Account don't have minter role."
        );
    });

    it('should have 20 quanitity in the first account' , async() => {
        const amount = 20;
        await maz.stakerMint(deployer, amount);
        const amountOfDeployer = await maz.balanceOf(deployer); 
        assert.equal(
            amount.toString(),
            amountOfDeployer.toString(),
            "First account don't have 20 MAZ."
        )
    });

    it('should be 30 as lastMintedTokenId' , async() => {
        const amount = 10;
        await maz.stakerMint(deployer, amount);
        const lastMintedTokenId = await maz._lastMintedTokenId(); 
        assert.equal(
            "30",
            lastMintedTokenId.toString(),
            "Last minted tokenId is not 30."
        )
    });

    it(`should have minter role in the second account - ${accounts[1]}` , async() => {
        await maz.setStakeMinter(accounts[1]);
        const role = await maz.hasRole(minterSignature, accounts[1]);
        assert.equal(
            role,
            true,
            "Second account don't have minter role."
        )
    });
});
