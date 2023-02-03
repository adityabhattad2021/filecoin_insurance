const { network } = require("hardhat");
const { developementChains } = require("../helper-hardhat-config");
require("dotenv").config();

module.exports = async function ({ getNamedAccounts, deployments }) {
	const { deploy, log } = deployments;
	const { deployer } = await getNamedAccounts();
	console.log(`------Deployer is ${deployer}------------`);

	const chainId = network.config.chainId;
	console.log(`------ChainId is ${chainId}------------`);

	// Duration between payments is 1 month in seconds
	const durationBetweenPayments = 2592000; // 1 month in seconds
	const inusranceDuration = 31104000;

	const args = [durationBetweenPayments, inusranceDuration];

	log("-------------------Deploying Filecoin Insurance Contract-------------------------");
	await deploy("FilecoinInsurance", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations:network.config.blockConfirmations || 1,
    })
	log(
		"-------------------Successfully Deployed Filecoin Insurance Contract-------------------------"
	);
};

module.exports.tags = ["all", "FilecoinInsurance"];
