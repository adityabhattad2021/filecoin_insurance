const {assert,expect}=require("chai");
const {getNamedAccounts,deployments,ethers,network}=require("hardhat")
const {developmentChains}=require("../../helper-hardhat-config");


!developmentChains.includes(network.name)
    ? describe.skip
    : describe("FilecoinInsurance Unit Tests", function () {
        let insuranceContract,deployer;

        beforeEach(async function () {
            deployer = (await getNamedAccounts()).deployer;
            await deployments.fixture(["all"]);
            insuranceContract = await ethers.getContract("FilecoinInsurance", deployer);
        });

        describe("Constructor", function (){
            it("Initializes the contract with the correct values", async function (){
                const durationBetweenPayments = await insuranceContract.getDurationBetweenPayments();
                const insuranceDuration = await insuranceContract.getInsuranceDuration();
                assert.equal(durationBetweenPayments,2592000);
                assert.equal(insuranceDuration,31104000);
            });
        });


        describe("Register a storage provider",function (){
            it("It can only be called by the owner",async function(){
                const SP=(await getNamedAccounts()).account1;
                const allAccounts = await ethers.getSigners();
                const insuranceContractConnectedToNotOwner=await insuranceContract.connect(allAccounts[1]);
                await expect(insuranceContractConnectedToNotOwner.registerStorageProvider(
                    SP,
                    "100000000000000000000",
                    "10000000000000000000000"
                )).to.be.reverted;

            })
            it("Register a storage provider",async function(){
                const SP=(await getNamedAccounts()).account1;
                const tx=await insuranceContract.registerStorageProvider(
                    SP,
                    "100000000000000000000",
                    "100000000000000000000000"
                );
                await tx.wait(1);
                const storageProvider=await insuranceContract.getRegisteredStorageProvider(SP);
                console.log(storageProvider);
                const isInsured=storageProvider.isInsured;
                const payeeAddress=storageProvider.payeeAddress;
                const timesPremiumPaid=storageProvider.timesPremiumPaid;
                // const premiumStartTime=storageProvider.premiumStartTime;
                // const premiumEndTime=storageProvider.premiumEndTime;
                // const timeOfLastPremiumPayment=storageProvider.timeOfLastPremiumPayment;
                const regularPremiumAmount=storageProvider.regularPremiumAmount;
                const claimAmount=storageProvider.claimAmount;
                const claimAmountPaid=storageProvider.claimPaid;
                assert.equal(isInsured,true);
                assert.equal(payeeAddress,SP);
                // premium start time is current time
                // assert.equal(parseInt(premiumStartTime)+1,Math.floor(Date.now()/1000));
                // premium end time is current time + insurance duration
                // assert.equal(parseInt(premiumEndTime)+1,Math.floor(Date.now()/1000)+31104000);
                // time of last premium payment is current time
                // assert.equal(parseInt(timeOfLastPremiumPayment),Math.floor(Date.now()/1000));
                // times premium paid is 0
                assert.equal(parseInt(timesPremiumPaid),0);
                // regular premium amount is 100000000000000000000
                assert.equal(parseInt(regularPremiumAmount),"100000000000000000000");
                // claim amount is 10000000000000000000000
                assert.equal(parseInt(claimAmount),"100000000000000000000000");
                // claim amount paid is 0
                assert.equal(claimAmountPaid,false);
            })
        })

    });