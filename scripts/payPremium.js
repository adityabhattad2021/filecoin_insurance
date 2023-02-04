const { ethers, getNamedAccounts } = require("hardhat");

async function main() {
	const { deployer, account1 } = await getNamedAccounts();
	const insuranceContract = await ethers.getContract("FilecoinInsurance");

	console.log(`------Paying the premium to the storage provider------------`);
	for (let i = 0; i < 1; i++) {
		network.provider.send("evm_increaseTime", [2592000]);
		network.provider.send("evm_mine", []);
		const allAccounts = await ethers.getSigners();
		const signerSP = allAccounts[1];
		const insuranceContractConnectedToSP = await insuranceContract.connect(
			signerSP
		);
		const tx2 = await insuranceContractConnectedToSP.getPremium(
			ethers.utils.parseEther("2"),
			{ value: ethers.utils.parseEther("200") }
		);
		await tx2.wait(1);
		console.log(
			`------Successfully paid the premium to the storage provider------------`
		);
	}
}

main()
	.then(() => {
		process.exit(0);
	})
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
