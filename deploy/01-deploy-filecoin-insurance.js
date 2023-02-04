const { network } = require("hardhat");
const { developementChains } = require("../helper-hardhat-config");
require("dotenv").config();

module.exports = async function ({ getNamedAccounts, deployments }) {
	const { deploy, log } = deployments;
	const { deployer } = await getNamedAccounts();
	console.log(`------Deployer is ${deployer}------------`);

	const chainId = network.config.chainId;
	console.log(`------ChainId is ${chainId}------------`);


	// Deploy Mocks
	log("-------------------Deploying Mocks-------------------------");
	const mockQueryAPI= await deploy("QueryAPI", {
		from: deployer,
		log: true,
		waitConfirmations:network.config.blockConfirmations || 1,
	});
	log("-------------------Successfully Deployed Mocks-------------------------");

	console.log(mockQueryAPI.address);

	argsForVerifier = [mockQueryAPI.address];
	// Deploy Verifier\
	log("-------------------Deploying Verifier-------------------------");
	const verifier = await deploy("Verifier", {
		from: deployer,
		log: true,
		args: argsForVerifier,
		waitConfirmations:network.config.blockConfirmations || 1,
	});	
	log("-------------------Successfully Deployed Verifier-------------------------");

	// Duration between payments is 1 month in seconds
	const durationBetweenPayments = 2592000; // 1 month in seconds
	const inusranceDuration = 31104000;
	const argsForInsurance = [ durationBetweenPayments, inusranceDuration, verifier.address];

	log("-------------------Deploying Filecoin Insurance Contract-------------------------");
	await deploy("FilecoinInsurance", {
        from: deployer,
        args: argsForInsurance,
        log: true,

        waitConfirmations:network.config.blockConfirmations || 1,
    })
	log(
		"-------------------Successfully Deployed Filecoin Insurance Contract-------------------------"
	);
};

module.exports.tags = ["all", "FilecoinInsurance"];
