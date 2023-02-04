const { ethers, getNamedAccounts } = require("hardhat");

async function main() {
	const { account1 } = await getNamedAccounts();
	const insuranceContract = await ethers.getContract("FilecoinInsurance");

	console.log(
		`------Registering the storage provider ${account1}------------`
	);
	const tx = await insuranceContract.registerStorageProvider(
		account1,
	);
	await tx.wait(1);
	console.log(
		`------Successfully registered the storage provider ${account1}------------`
	);


}

main()
	.then(() => {
		process.exit(0);
	})
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
