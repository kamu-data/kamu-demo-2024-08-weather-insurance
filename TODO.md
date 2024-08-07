<div align="center">

<img alt="Open Data Fabric Network" src="docs/readme_files/kamu_logo.png" width=350/>

<p>

[![Chat](https://shields.io/discord/898726370199359498?style=for-the-badge&logo=discord&label=Discord)](https://discord.gg/nU6TXRQNXC)

</p>
</div>



# =================== TODOs ===================

- CLI
  - release `kamu add --name`
  - prevent structs in schema
  - check `kamu ui` can run with WSL2
- Oracle
  - killing oracle with one invalid SQL (retry death loop)
  - pass arbitrary payload with request
  - pass request parameters as `$var`
  - ability to self-deliver signed responses (reconcile with commitment RFC)
- Remove secrets from demo repo
- Include weather data into examples?


## About

Ethereum Sepolia Testnet: [0xf52BC7bE133a4CB3799Bfe6399bc576465f28153](https://sepolia.etherscan.io/address/0xf52BC7bE133a4CB3799Bfe6399bc576465f28153)

### Contract

```sh
nvm use
npm ci
npm run deploy
npm run applyForCoverage
POLICY_ID=123 npm run bidForCoverage
POLICY_ID=123 npm run settle
```

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
