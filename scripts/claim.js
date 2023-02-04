const { ethers, getNamedAccounts } = require("hardhat");

async function main() {
	const insuranceContract = await ethers.getContract("FilecoinInsurance");

	console.log(`--------Claim for Insurance ----------`);
	const allAccounts = await ethers.getSigners();
	const signerSP = allAccounts[1];
	const insuranceContractConnectedToSP = await insuranceContract.connect(
		signerSP
	);
	const tx1 = await insuranceContractConnectedToSP.raiseClaimRequest();
	await tx1.wait(1);
	console.log(`--------Successfully Claimed for Insurance ----------`);
}

main()
	.then(() => {
		process.exit(0);
	})
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
