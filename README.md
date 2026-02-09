# NFT Minting Smart Contract (Foundry + Yul)

A production-grade ERC-721 NFT minting smart contract built with **Foundry** and
**selective Yul assembly** for gas-critical execution paths.

This project demonstrates strong EVM fundamentals, security-first design, and
engineering judgment when balancing low-level optimization with readability
and auditability.

---

##  Key Features

- ERC-721 compliant NFT contract
- Public sale and presale minting
- Merkle Tree whitelist for presale access
- Per-wallet presale mint limits
- Max supply enforcement
- Reentrancy protection
- Custom Solidity errors
- **Yul-optimized minting & payment validation**
- Fully tested with Foundry + fuzzing

---

##  Design Philosophy

This contract intentionally uses a **hybrid approach**:

- **Solidity** for:
  - ERC-721 standard compliance
  - Ownership and access control
  - Merkle proof verification
  - Readability and auditability

- **Yul (inline assembly)** for:
  - ETH payment validation
  - Token ID counter updates
  - Supply enforcement
  - Gas-optimized mint loops

This reflects real-world production practices where Yul is applied **only to
hot paths** rather than entire contracts.

---

##  Tech Stack

- Solidity `^0.8.26`
- Foundry (`forge`, `cast`)
- OpenZeppelin Contracts
- Yul / EVM Assembly
- Merkle Trees (whitelisting)

---

##  Security Considerations

- `ReentrancyGuard` used on all payable mint functions
- No use of `tx.origin`
- Explicit supply and payment validation
- Custom errors reduce gas and improve revert clarity
- Yul blocks are small, isolated, and auditable
- No unbounded loops beyond user-supplied mint amount

---

##  Testing

The project includes Foundry tests covering:

- Successful public minting
- Payment validation failures
- Max supply enforcement
- Sale state restrictions
- Ownership correctness
- Fuzz testing for variable mint amounts

### Run tests
```bash
forge test

## Run with gas report
```bash
forge test --gas-report



## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
