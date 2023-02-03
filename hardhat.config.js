require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const HYPERSPACE_RPC_URL= process.env.HYPERSPACE_RPC_URL;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
	solidity: "0.8.17",
	defaultNetwork: "hardhat",
	networks: {
		hardhat: {
			chainId: 1337,
			blockConfirmations: 1,
		},
		localhost: {
			chainId: 1337,
			blockConfirmations: 1,
		},
		hyperspace: {
			chainId: 3141,
			url: HYPERSPACE_RPC_URL,
			accounts: [PRIVATE_KEY],
		},
	},
	namedAccounts: {
		deployer: {
			default: 0,
		},
		contestant1: {
			default: 1,
		},
		contestant2: {
			default: 2,
		},
	},
	settings: {
		optimizer: {
			enabled: true,
			runs: 200,
		},
	},
	mocha: {
		timeout: 500000, // 500 seconds.
	},
};
