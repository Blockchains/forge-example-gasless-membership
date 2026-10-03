# Gasless Membership Club (ERC-4337 + ERC-721)

[![CI](https://github.com/Blockchains/forge-example-gasless-membership/actions/workflows/ci.yml/badge.svg)](https://github.com/Blockchains/forge-example-gasless-membership/actions/workflows/ci.yml) [![Pages](https://github.com/Blockchains/forge-example-gasless-membership/actions/workflows/pages.yml/badge.svg)](https://blockchains.github.io/forge-example-gasless-membership/) [![Open in Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/Blockchains/forge-example-gasless-membership?quickstart=1)

> **Idea:** Gasless membership club: each member gets a smart account (account abstraction) and mints a membership NFT without holding ETH; the club sponsors gas with a paymaster and an admin role manages who is allowed.

This repository was composed automatically by **[Blockchain Lab Forge](https://blockchainlab.com/forge)**. Forge parsed the idea into capabilities (`account-abstraction`, `nft`, `access-control`), retrieved matching components from the [Blockchains fork index](https://github.com/Blockchains/blockchainlab-index), pinned them to release tags, copied their exact source files (with full import closure) from the Blockchains forks, and added glue code, tests, a deploy script and a web front end.

## What it does
- **`MembershipNFT`** (glue, MIT). One membership pass per approved account. An `APPROVER_ROLE` manages the allowlist. Passes are non-transferable by default, and an admin can enable transfers.
- **`ClubPaymaster`** (glue, GPL-3.0, extends eth-infinitism `BasePaymaster` v0.9.0). It sponsors gas for exactly one operation: an approved account that is not yet a member calling `MembershipNFT.join()` through its smart account.
- Members use eth-infinitism **`SimpleAccount`** smart accounts, deployed counterfactually by **`SimpleAccountFactory`** in the same UserOperation that mints the pass. They need no ETH at any point.

## Run it
```bash
git clone --recursive https://github.com/Blockchains/forge-example-gasless-membership && cd forge-example-gasless-membership
forge test -vv            # 5 local tests on the real v0.9.0 EntryPoint + 1 Sepolia fork test on the canonical EntryPoint 0x4337...D009
cd web && npm ci && npm run dev   # front end: live Sepolia reads + one-click wallet deployment
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --account deployer --broadcast
```
Live front end: https://blockchains.github.io/forge-example-gasless-membership/

## Layout
```
src/MembershipNFT.sol, src/ClubPaymaster.sol      glue code
test/GaslessMembership.t.sol                      local + Sepolia-fork tests
script/Deploy.s.sol                               deploy factory, club, paymaster (+ deposit)
lib/account-abstraction/... lib/openzeppelin-contracts/...   copied sources (pinned tags v0.9.0, v5.7.0)
lib/forge-std                                     submodule (Blockchains/forge-std)
web/                                              Vite + viem front end (GitHub Pages)
component-map.json, plan.json, NOTICE             provenance
```


## Component map
| Capability | Component | From | Licence |
|---|---|---|---|
| account-abstraction (primary) | [`BasePaymaster`](https://github.com/Blockchains/account-abstraction/blob/b36a1ed52ae00da6f8a4c8d50181e2877e4fa410/contracts/core/BasePaymaster.sol) | [Blockchains/account-abstraction](https://github.com/Blockchains/account-abstraction) (upstream [eth-infinitism/account-abstraction](https://github.com/eth-infinitism/account-abstraction)) | MIT |
| account-abstraction (companion) | [`SimpleAccount`](https://github.com/Blockchains/account-abstraction/blob/b36a1ed52ae00da6f8a4c8d50181e2877e4fa410/contracts/accounts/SimpleAccount.sol) | [Blockchains/account-abstraction](https://github.com/Blockchains/account-abstraction) (upstream [eth-infinitism/account-abstraction](https://github.com/eth-infinitism/account-abstraction)) | MIT |
| account-abstraction (companion) | [`SimpleAccountFactory`](https://github.com/Blockchains/account-abstraction/blob/b36a1ed52ae00da6f8a4c8d50181e2877e4fa410/contracts/accounts/SimpleAccountFactory.sol) | [Blockchains/account-abstraction](https://github.com/Blockchains/account-abstraction) (upstream [eth-infinitism/account-abstraction](https://github.com/eth-infinitism/account-abstraction)) | MIT |
| account-abstraction (companion) | [`EntryPoint`](https://github.com/Blockchains/account-abstraction/blob/b36a1ed52ae00da6f8a4c8d50181e2877e4fa410/contracts/core/EntryPoint.sol) | [Blockchains/account-abstraction](https://github.com/Blockchains/account-abstraction) (upstream [eth-infinitism/account-abstraction](https://github.com/eth-infinitism/account-abstraction)) | GPL-3.0 |
| nft (primary) | [`ERC721`](https://github.com/Blockchains/openzeppelin-contracts/blob/cab19933c33c2ad1d4c7a84864a3601dddfd16f3/contracts/token/ERC721/ERC721.sol) | [Blockchains/openzeppelin-contracts](https://github.com/Blockchains/openzeppelin-contracts) (upstream [OpenZeppelin/openzeppelin-contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)) | MIT |
| nft (companion) | [`ERC721URIStorage`](https://github.com/Blockchains/openzeppelin-contracts/blob/cab19933c33c2ad1d4c7a84864a3601dddfd16f3/contracts/token/ERC721/extensions/ERC721URIStorage.sol) | [Blockchains/openzeppelin-contracts](https://github.com/Blockchains/openzeppelin-contracts) (upstream [OpenZeppelin/openzeppelin-contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)) | MIT |
| access-control (primary) | [`AccessControl`](https://github.com/Blockchains/openzeppelin-contracts/blob/cab19933c33c2ad1d4c7a84864a3601dddfd16f3/contracts/access/AccessControl.sol) | [Blockchains/openzeppelin-contracts](https://github.com/Blockchains/openzeppelin-contracts) (upstream [OpenZeppelin/openzeppelin-contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)) | MIT |
| access-control (companion) | [`Ownable`](https://github.com/Blockchains/openzeppelin-contracts/blob/cab19933c33c2ad1d4c7a84864a3601dddfd16f3/contracts/access/Ownable.sol) | [Blockchains/openzeppelin-contracts](https://github.com/Blockchains/openzeppelin-contracts) (upstream [OpenZeppelin/openzeppelin-contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)) | MIT |

Copied sources (unmodified, under `lib/<project>/`, listed file by file in [NOTICE](NOTICE)):

| Fork | Pinned | Files |
|---|---|---|
| [Blockchains/openzeppelin-contracts](https://github.com/Blockchains/openzeppelin-contracts/tree/cab19933c33c2ad1d4c7a84864a3601dddfd16f3) | v5.7.0 | 42 |
| [Blockchains/account-abstraction](https://github.com/Blockchains/account-abstraction/tree/b36a1ed52ae00da6f8a4c8d50181e2877e4fa410) | v0.9.0 | 23 |

Machine-readable: [`component-map.json`](component-map.json) · plan: [`plan.json`](plan.json)

## Licence
**GPL-3.0-or-later**. Includes strong-copyleft files (GPL-3.0); the composed project is distributed under GPL terms. Every copied file keeps its original SPDX header. Attribution is in [NOTICE](NOTICE).

Not audited. Review the code yourself before you put real value on mainnet.
