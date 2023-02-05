const { network } = require("hardhat");
const {
	developementChains,
	developmentChains,
} = require("../helper-hardhat-config");
require("dotenv").config();
const util = require("util")
const request = util.promisify(require("request"))
require("hardhat-deploy");
require("hardhat-deploy-ethers");

async function callRpc(method, params) {
	var options = {
		method: "POST",
		url: "https://api.hyperspace.node.glif.io/rpc/v1",
		// url: "http://localhost:1234/rpc/v0",
		headers: {
			"Content-Type": "application/json",
		},
		body: JSON.stringify({
			jsonrpc: "2.0",
			method: method,
			params: params,
			id: 1,
		}),
	};
	const res = await request(options);
	return JSON.parse(res.body).result;
}

module.exports = async function ({ getNamedAccounts, deployments }) {
	const { deploy, log } = deployments;
	const { deployer } = await getNamedAccounts();
	console.log(`------Deployer is ${deployer}------------`);

	const chainId = network.config.chainId;
	console.log(`------ChainId is ${chainId}------------`);

	const priorityFee = await callRpc("eth_maxPriorityFeePerGas");

	// Wraps Hardhat's deploy, logging errors to console.
	const deployLogError = async (title, obj) => {
		let ret;
		try {
			ret = await deploy(title, obj);
		} catch (error) {
			console.log(error.toString());
			process.exit(1);
		}
		return ret;
	};

	if (developmentChains.includes(network.name)) {
		// Deploy Mocks
		log("-------------------Deploying Mocks-------------------------");
		const mockQueryAPI = await deploy("QueryAPI", {
			from: deployer,
			log: true,
			waitConfirmations: network.config.blockConfirmations || 1,
		});
		log(
			"-------------------Successfully Deployed Mocks-------------------------"
		);

		console.log(mockQueryAPI.address);

		argsForVerifier = [mockQueryAPI.address];
		// Deploy Verifier\
		log("-------------------Deploying Verifier-------------------------");
		const verifier = await deploy("Verifier", {
			from: deployer,
			log: true,
			args: argsForVerifier,
			waitConfirmations: network.config.blockConfirmations || 1,
		});
		log(
			"-------------------Successfully Deployed Verifier-------------------------"
		);

		// Duration between payments is 1 month in seconds
		const durationBetweenPayments = 2592000; // 1 month in seconds
		const inusranceDuration = 31104000;
		const argsForInsurance = [
			durationBetweenPayments,
			inusranceDuration,
			verifier.address,
		];

		log(
			"-------------------Deploying Filecoin Insurance Contract-------------------------"
		);
		await deploy("FilecoinInsurance", {
			from: deployer,
			args: argsForInsurance,
			log: true,

			waitConfirmations: network.config.blockConfirmations || 1,
		});
		log(
			"-------------------Successfully Deployed Filecoin Insurance Contract-------------------------"
		);
	}
	log("-------------------Deploying Mocks-------------------------");
	const mockQueryAPI = await deployLogError("QueryAPI", {
		from: deployer,
		log: true,
		args:[],
		maxPriorityFeePerGas: priorityFee,
	});
	log(
		"-------------------Successfully Deployed Mocks-------------------------"
	);

	console.log(mockQueryAPI.address);

	argsForVerifier = [mockQueryAPI.address];
	// Deploy Verifier\
	log("-------------------Deploying Verifier-------------------------");
	const verifier = await deployLogError("Verifier", {
		from: deployer,
		log: true,
		args: argsForVerifier,
		maxPriorityFeePerGas: priorityFee,
	});
	log(
		"-------------------Successfully Deployed Verifier-------------------------"
	);

	// Duration between payments is 1 month in seconds
	const durationBetweenPayments = 2592000; // 1 month in seconds
	const inusranceDuration = 31104000;
	const argsForInsurance = [
		durationBetweenPayments,
		inusranceDuration,
		verifier.address,
	];

	log(
		"-------------------Deploying Filecoin Insurance Contract-------------------------"
	);
	await deployLogError("FilecoinInsurance", {
		from: deployer,
		args: argsForInsurance,
		log: true,
		maxPriorityFeePerGas: priorityFee,
	});
	log(
		"-------------------Successfully Deployed Filecoin Insurance Contract-------------------------"
	);
};

module.exports.tags = ["all", "FilecoinInsurance"];
