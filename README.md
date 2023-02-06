# Filecoin Insurance Smart Contract

## Current Flow of the Project
![FLow1](https://user-images.githubusercontent.com/93488388/216699174-8c003d7f-9933-4994-826a-85554bfa0e4e.jpeg)


The premuim and the claim amount are calculated based on the information returned from the query to the blockchain. This will be proportional to the sector size. While requestiong claim from the smart contract the storage provider will have to hand over the benificiary address (this can be changed using the MinorAPI provided in future) which will verifed and the funds will be released to the storage provider.  


## Try it out locally
Step 1.
```shell
git clone https://github.com/adityabhattad2021/filecoin_insurance.git
cd filecoin_insurance
yarn
```

Step 2.
```Create a .env folder and configure the required keys```

Step 3.
 - To run tests:
```shell
yarn hardhat test
```

 - To check coverage
```shell
yarn hardhat coverage
```



 

### Interact with the smart contract using scripts.
 
- Register the Storage Provider
```shell
yarn hardhat node
yarn hardhat run scripts/registerStorageProvider.js --network localhost
```


- Pay Insurance from the storage provider account
```shell
yarn hardhat node
yarn hardhat run scripts/payPremium.js --network localhost
```


 - Claim Insurance if valid
```shell
yarn hardhat node
yarn hardhat run scripts/claim.js --network localhost
```
 


