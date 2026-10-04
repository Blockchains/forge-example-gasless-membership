# AGENTS.md: forge-example-gasless-membership

Instructions for AI coding agents (Grok, Cursor, Claude Code, Codex, Copilot and others) working **in** this repo or **using it as a building block**. Humans: see [README.md](README.md).

## What this is

Composed gasless membership club: ERC-721 pass with an approver allowlist (MembershipNFT) and an ERC-4337 paymaster that sponsors exactly the join() UserOperation (ClubPaymaster, extends eth-infinitism BasePaymaster v0.9.0), plus a viem front end.

- Kind: contracts, web-app · stability: `reference` · licence: GPL-3.0-or-later
- Machine-readable manifest: [`blocks.json`](blocks.json) (schema: [BLOCKS-SCHEMA](https://github.com/Blockchains/.github/blob/main/docs/BLOCKS-SCHEMA.md))
- How it fits with the other Blockchains repos: [Build with Blocks](https://github.com/Blockchains/.github/blob/main/docs/BUILD-WITH-BLOCKS.md)

## Setup

```bash
git clone --recursive https://github.com/Blockchains/forge-example-gasless-membership && cd forge-example-gasless-membership
foundryup
cd web && npm ci
```

## Build and test

```bash
forge build --sizes
forge test -vv   # set MAINNET_RPC_URL / SEPOLIA_RPC_URL to include fork tests
cd web && npm ci && npm test && npm run build
```

Tests hit **live** public networks/APIs (the org rule is no mocks). A failure can be an upstream outage: re-run before changing code.

## Environment

| Variable | Required | Purpose |
|---|---|---|
| `MAINNET_RPC_URL` | no | enables live-chain fork tests |
| `SEPOLIA_RPC_URL` | no | deploy target |
| `DEPLOYER_PRIVATE_KEY` | no | repo secret for the Deploy workflow only; never in files |

## Structure

| Path | What |
|---|---|
| `src/MembershipNFT.sol` | glue contract |
| `src/ClubPaymaster.sol` | glue contract |
| `test/` | Foundry tests (unit + fork) |
| `script/Deploy.s.sol` | deployment |
| `lib/` | copied, unmodified components + forge-std |
| `component-map.json, plan.json, NOTICE` | provenance and attribution |
| `web/` | Vite + viem front end (GitHub Pages) |

## Conventions

- Files under `lib/` are copied unmodified from Blockchains forks with SPDX headers; do not edit them.
- Glue lives in `src/`; tests cover every role and revert path.
- solc 0.8.30, evm_version cancun (foundry.toml).

## Extension points

- Import the contracts from another Foundry project: `forge install Blockchains/<this repo>` plus the full fork the components were copied from (e.g. `Blockchains/openzeppelin-contracts@v5.7.0`, `Blockchains/account-abstraction@v0.9.0`) and remap to it; `lib/` here holds only the files this project needs, so a remap to it can miss files another contract imports.
- Re-compose a variant with the composer instead of hand-editing when the change is a new capability.

## Do

- Keep NOTICE and component-map.json accurate if you add copied files.

## Don't

- Modify copied files under `lib/`.
- Put keys in scripts; use `--account <keystore>` or CI secrets.
- Commit secrets, keys or `.env` files. Run `gitleaks` before pushing; CI and the org policy reject leaks.

## Using it from another project

- **MembershipNFT** (solidity): `forge install Blockchains/forge-example-gasless-membership`
- **ClubPaymaster** (solidity): `forge install Blockchains/forge-example-gasless-membership`
- **script/Deploy.s.sol** (file): `forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --account <keystore> --broadcast`
- **component-map.json, plan.json** (file): `provenance: capability → component → pinned fork commit`
- **web/** (web): `cd web && npm ci && npm run dev`

See the README section [Use as a building block](README.md#use-as-a-building-block) for a copy-paste example.

## Related blocks

- [Blockchains/blockchainlab-index](https://github.com/Blockchains/blockchainlab-index): the composer that generated this repo
- [Blockchains/blockchainlab-index](https://github.com/Blockchains/blockchainlab-index): components were retrieved from the index
- [Blockchains/blockchainlab-starters](https://github.com/Blockchains/blockchainlab-starters): erc4337-smart-account starter
- [Blockchains/blockchainlab-sdk](https://github.com/Blockchains/blockchainlab-sdk): RPC health for the front end
