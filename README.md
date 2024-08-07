<div align="center">

<img alt="Kamu Planet-Scale Data Pipeline" src="docs/readme_files/kamu_logo.png" width=350/>

<p>

[![Chat](https://shields.io/discord/898726370199359498?style=for-the-badge&logo=discord&label=Discord)](https://discord.gg/nU6TXRQNXC)

</p>
</div>

## About

This repository contains the code that accompanies the blog post ["Web3 Data Crash Course"]() where you can find a step-by step walkthrough.

The smart contract used in the post is deployed on Ethereum Sepolia Testnet: [0xf52BC7bE133a4CB3799Bfe6399bc576465f28153](https://sepolia.etherscan.io/address/0xf52BC7bE133a4CB3799Bfe6399bc576465f28153)

## Building and testing
You will need the following tools:
- Nodejs - we recommend installing via [`nvm`](https://github.com/nvm-sh/nvm)
- [Foundry](https://github.com/foundry-rs/foundry)

To initialize the dependencies use:
```sh
cd contract
nvm use
npm ci
```

To build and test the contract use:
```sh
foundry test
```

## Deploying and using the contract
You will need 3 blockchain wallets:
- Admin wallet for deploying the contracts
- Holder wallet for holder of the insurance
- Insurer wallet for the insurance provider

Note that you can use just one wallet for all these roles but it may be a bit confusing in Etherscan.

Specify the wallets addresses and their private keys in `.env` file.

All wallets will need a little bit of Sepolia ETH which you can get from:
- [ChainLink faucet](https://faucets.chain.link/sepolia) (requires GitHub account)
- [Infura faucet](https://www.infura.io/faucet/sepolia) (requires Infura account)

To deploy the contract run:
```sh
npm run deploy
```

Note the new contract address and put it into the `.env` file.

To user the contract run:
```sh
npm run applyForCoverage
POLICY_ID=1 npm run bidForCoverage
POLICY_ID=1 npm run settle
```

The `applyForCoverage` call will return an incremented policy ID with each call, so don't forget to update it.

---

<div align="center">
  
[Website] | [Docs] | [Tutorials] | [Examples] | [FAQ] | [Chat] | [Contributing] | [Developer Guide] | [License]

</div>

[Tutorials]: https://docs.kamu.dev/cli/learn/learning-materials/
[Examples]: https://docs.kamu.dev/cli/learn/examples/
[Docs]: https://docs.kamu.dev/cli/
[Documentation]: https://docs.kamu.dev/cli/
[Demo]: https://docs.kamu.dev/cli/get-started/self-serve-demo/
[FAQ]: https://docs.kamu.dev/cli/get-started/faq/
[Chat]: https://discord.gg/nU6TXRQNXC
[Contributing]: https://docs.kamu.dev/contrib/
[Developer Guide]: ./DEVELOPER.md
[License]: https://docs.kamu.dev/contrib/license/
[Website]: https://kamu.dev
