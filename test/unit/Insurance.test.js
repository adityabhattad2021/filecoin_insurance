const { assert, expect } = require("chai");
const { getNamedAccounts, deployments, ethers, network } = require("hardhat");
const { developmentChains } = require("../../helper-hardhat-config");

!developmentChains.includes(network.name)
	? describe.skip
	: describe("FilecoinInsurance Unit Tests", function () {
			let insuranceContract, deployer;

			beforeEach(async function () {
				deployer = (await getNamedAccounts()).deployer;
				await deployments.fixture(["all"]);
				insuranceContract = await ethers.getContract(
					"FilecoinInsurance",
					deployer
				);
				verifierContract = await ethers.getContract(
					"Verifier",
					deployer
				);
				queryMockContract = await ethers.getContract(
					"QueryAPI",
					deployer
				);
			});

			describe("Constructor", function () {
				it("Initializes the contract with the correct values", async function () {
					const durationBetweenPayments =
						await insuranceContract.getDurationBetweenPayments();
					const insuranceDuration =
						await insuranceContract.getInsuranceDuration();

					assert.equal(durationBetweenPayments, 2592000);
					assert.equal(insuranceDuration, 31104000);
				});
			});

			describe("Register a storage provider", function () {
				it("It can only be called by the owner", async function () {
					const SP = (await getNamedAccounts()).account1;
					const allAccounts = await ethers.getSigners();
					const insuranceContractConnectedToNotOwner =
						await insuranceContract.connect(allAccounts[1]);
					await expect(
						insuranceContractConnectedToNotOwner.registerStorageProvider(
							SP
						)
					).to.be.reverted;
				});
				it("Register a storage provider", async function () {
					const SP = (await getNamedAccounts()).account1;
					const tx = await insuranceContract.registerStorageProvider(
						SP
					);
					await tx.wait(1);
					const storageProvider =
						await insuranceContract.getRegisteredStorageProvider(
							SP
						);
					const isInsured = storageProvider.isInsured;
					const payeeAddress = storageProvider.payeeAddress;
					const timesPremiumPaid = storageProvider.timesPremiumPaid;
					// const premiumStartTime=storageProvider.premiumStartTime;
					// const premiumEndTime=storageProvider.premiumEndTime;
					// const timeOfLastPremiumPayment=storageProvider.timeOfLastPremiumPayment;
					const claimAmountPaid = storageProvider.claimPaid;
					assert.equal(isInsured, true);
					assert.equal(payeeAddress, SP);
					// premium start time is current time
					// assert.equal(parseInt(premiumStartTime)+1,Math.floor(Date.now()/1000));
					// premium end time is current time + insurance duration
					// assert.equal(parseInt(premiumEndTime)+1,Math.floor(Date.now()/1000)+31104000);
					// time of last premium payment is current time
					// assert.equal(parseInt(timeOfLastPremiumPayment),Math.floor(Date.now()/1000));
					// times premium paid is 0
					assert.equal(parseInt(timesPremiumPaid), 0);
					assert.equal(claimAmountPaid, false);
				});
			});
			describe("Pay premium", function () {
				it("throws an error if the storage provider is not registered", async function () {
					const allAccounts = await ethers.getSigners();
					const insuranceContractConnectedToNotOwner =
						await insuranceContract.connect(allAccounts[1]);
					await expect(
						insuranceContractConnectedToNotOwner.getPremium(
							ethers.utils.parseEther("2"),
							{ value: ethers.utils.parseEther("200") }
						)
					).to.be.reverted;
				});

				it("throws an error if the premium amount is not equal to the regular premium amount", async function () {
					const SP = (await getNamedAccounts()).account1;
					const tx = await insuranceContract.registerStorageProvider(
						SP
					);
					await tx.wait(1);
					const allAccounts = await ethers.getSigners();
					const signerSP = allAccounts[1];
					const insuranceContractConnectedToSP =
						await insuranceContract.connect(signerSP);
					await expect(
						insuranceContractConnectedToSP.getPremium(
							ethers.utils.parseEther("2"),
							{ value: ethers.utils.parseEther("100") }
						)
					).to.be.reverted;
				});

				it("throws error if premium payment time not reached", async function () {
					const SP = (await getNamedAccounts()).account1;
					const tx = await insuranceContract.registerStorageProvider(
						SP
					);
					await tx.wait(1);
					const allAccounts = await ethers.getSigners();
					const signerSP = allAccounts[1];
					const insuranceContractConnectedToSP =
						await insuranceContract.connect(signerSP);
					await expect(
						insuranceContractConnectedToSP.getPremium(
							ethers.utils.parseEther("2"),
							{ value: ethers.utils.parseEther("200") }
						)
					).to.be.reverted;
				});

				it("throws error if previous premium payment not made", async function () {
					const SP = (await getNamedAccounts()).account1;
					const tx = await insuranceContract.registerStorageProvider(
						SP
					);
					await tx.wait(1);
					network.provider.send("evm_increaseTime", [2592000 * 2]);
					network.provider.send("evm_mine", []);
					const allAccounts = await ethers.getSigners();
					const signerSP = allAccounts[1];
					const insuranceContractConnectedToSP =
						await insuranceContract.connect(signerSP);
					await expect(
						insuranceContractConnectedToSP.getPremium(
							ethers.utils.parseEther("2"),
							{ value: ethers.utils.parseEther("200") }
						)
					).to.be.reverted;
				});

				it("get premium from storage provider", async function () {
					const SP = (await getNamedAccounts()).account1;

					const tx = await insuranceContract.registerStorageProvider(
						SP
					);
					await tx.wait(1);

					network.provider.send("evm_increaseTime", [2592000]);
					network.provider.send("evm_mine", []);
					const regularPremiumAmount =
						await insuranceContract.getPremiumAmount(SP);
					const allAccounts = await ethers.getSigners();
					const signerSP = allAccounts[1];
					const insuranceContractConnectedToSP =
						await insuranceContract.connect(signerSP);

					const tx2 = await insuranceContractConnectedToSP.getPremium(
						ethers.utils.parseEther("2"),
						{
							value: (
								parseInt(regularPremiumAmount) / 2
							).toString(),
						}
					);
					await tx2.wait(1);

					const storageProvider =
						await insuranceContract.getRegisteredStorageProvider(
							SP
						);

					const timesPremiumPaid = storageProvider.timesPremiumPaid;
					// const timeOfLastPremiumPayment=storageProvider.timeOfLastPremiumPayment;
					const claimAmountPaid = storageProvider.claimPaid;
					assert.equal(parseInt(timesPremiumPaid), 1);
					// assert.equal(parseInt(timeOfLastPremiumPayment),Math.floor(Date.now()/1000),"Time of last premium paid do not match");
					assert.equal(claimAmountPaid, false);
				});
			});
			describe("Claim", function () {
				it("throws an error if the storage provider is not registered", async function () {
					const allAccounts = await ethers.getSigners();
					const insuranceContractConnectedToNotOwner =
						await insuranceContract.connect(allAccounts[1]);
					await expect(
						insuranceContractConnectedToNotOwner.raiseClaimRequest()
					).to.be.reverted;
				});
				it("throws an error if the insurance is expired", async function () {
					const SP = (await getNamedAccounts()).account1;
					const tx = await insuranceContract.registerStorageProvider(
						SP
					);
					await tx.wait(1);
					network.provider.send("evm_increaseTime", [2592000 * 13]);
					network.provider.send("evm_mine", []);
					const allAccounts = await ethers.getSigners();
					const signerSP = allAccounts[1];
					const insuranceContractConnectedToSP =
						await insuranceContract.connect(signerSP);
					await expect(
						insuranceContractConnectedToSP.raiseClaimRequest()
					).to.be.reverted;
				});
				it("pays the storage provider if the claim is valid", async function () {
					const SP = (await getNamedAccounts()).account1;
					const tx = await insuranceContract.registerStorageProvider(
						SP
					);
					await tx.wait(1);

					for (let i = 0; i < 10; i++) {
						network.provider.send("evm_increaseTime", [2592000]);
						network.provider.send("evm_mine", []);
						const regularPremiumAmount =
							await insuranceContract.getPremiumAmount(SP);
						const allAccounts = await ethers.getSigners();
						const signerSP = allAccounts[1];
						const insuranceContractConnectedToSP =
							await insuranceContract.connect(signerSP);

						const tx2 =
							await insuranceContractConnectedToSP.getPremium(
								ethers.utils.parseEther("2"),
								{
									value: (
										parseInt(regularPremiumAmount) / 2
									).toString(),
								}
							);
						await tx2.wait(1);
					}

                    const balanceBefore = await ethers.provider.getBalance(SP);
					const allAccounts = await ethers.getSigners();
					const signerSP = allAccounts[1];
					const insuranceContractConnectedToSP =
						await insuranceContract.connect(signerSP);
					const tx2 =
						await insuranceContractConnectedToSP.raiseClaimRequest();
					await tx2.wait(1);
					const storageProvider =
						await insuranceContract.getRegisteredStorageProvider(
							SP
						);
					const claimAmountPaid = storageProvider.claimPaid;
					assert.equal(claimAmountPaid, true);

                    const balanceAfter = await ethers.provider.getBalance(SP);


                    assert.equal(parseInt(balanceAfter)>parseInt(balanceBefore),true);

				});
			});
	  });
