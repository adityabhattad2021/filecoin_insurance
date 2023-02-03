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
        })

    });