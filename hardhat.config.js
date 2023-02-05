require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("hardhat-deploy-ethers")
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
		account1: {
			default: 1,
		},
		account2: {
			default: 2,
		},
	},
	paths: {
        sources: "./contracts",
        tests: "./test",
        cache: "./cache",
        artifacts: "./artifacts",
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
