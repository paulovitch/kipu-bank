# 📘 README.md — **KipuBank**

```markdown
# 🏦 KipuBank

### A minimal ETH vault contract built for educational purposes (Module 2 – ETH Kipu Bootcamp).

---

## 📜 Overview

KipuBank is a smart contract that allows users to **deposit and withdraw native ETH** into personal vaults, 
while enforcing both a **per-transaction withdrawal cap** and a **global deposit limit (bankCap)**.

It was designed and deployed as the final project of Module 2 to demonstrate:
- secure contract architecture using **custom errors**,  
- adherence to **Checks → Effects → Interactions (CEI)** pattern,  
- proper use of **modifiers** and **NatSpec**,  
- and clean, auditable code structure.

---

## ⚙️ Features

- 🧱 **Immutable configuration**  
  - `withdrawPerTxCap` and `bankCap` are set once at deployment.
- 💰 **Deposits and Withdrawals**  
  - Users can deposit ETH into a personal vault (`deposit()`).
  - Withdrawals are limited by `withdrawPerTxCap` (`withdraw()`).
- 🔐 **Global deposit limit**  
  - Prevents total vault value from exceeding `bankCap`.
- 🧩 **Events & Tracking**  
  - Emits `Deposited` and `Withdrawn` events for every transaction.
  - Tracks total deposits and withdrawals with on-chain counters.
- 🧯 **Security**  
  - Uses **custom errors** instead of `require` strings.
  - Respects **least privilege** and encapsulation.
  - **Rejects direct ETH transfers** via `receive()` and `fallback()`.

---

## 🧰 Tech & Design Patterns

| Aspect | Implementation |
|--------|----------------|
| Validation | Custom errors + Modifiers |
| Logic Flow | Checks → Effects → Interactions |
| Gas Optimization | `unchecked` blocks for safe counters |
| Visibility | `private` state + explicit getters |
| Documentation | Full **NatSpec** coverage |
| Security | CEI + no reentrancy risk |

---

## 🧩 Contract Structure

```

KipuBank.sol
├── ERRORS
├── EVENTS
├── STATE VARIABLES
├── CONSTRUCTOR
├── MODIFIERS
├── EXTERNAL FUNCTIONS
│   ├── deposit()
│   └── withdraw(uint256)
├── INTERNAL FUNCTION
│   └── _bumpDeposits()
├── VIEW GETTERS
│   ├── balanceOf(address)
│   ├── totalVaulted()
│   ├── totalDeposits()
│   ├── totalWithdrawals()
│   ├── getWithdrawPerTxCap()
│   └── getBankCap()
└── RECEIVE / FALLBACK

````

---

## 🧪 Deployment

### 1. Compile
Use **Remix IDE** or **Hardhat** with Solidity `^0.8.19`.

### 2. Deploy parameters
When deploying, provide:

```solidity
constructor(uint256 _withdrawPerTxCap, uint256 _bankCap)
````

Example:

```
withdrawPerTxCap = 0.2 ether
bankCap = 5 ether
```

---

## 🔍 Verified Contract

* **Network:** Sepolia Testnet
* **Address:** `0xYOUR_CONTRACT_ADDRESS`
* **Compiler Version:** 0.8.19
* **EVM Version:** Default
* **License:** MIT

(Replace with your actual verified contract address.)

---

## 💻 Interaction

### Deposit ETH

Call:

```solidity
deposit()
```

Send ETH along with the call (`msg.value > 0`).

### Withdraw ETH

Call:

```solidity
withdraw(uint256 amount)
```

* Must be ≤ your vault balance.
* Must be ≤ `withdrawPerTxCap`.

### Read data

| Function                | Description                      |
| ----------------------- | -------------------------------- |
| `balanceOf(address)`    | Returns vault balance of user    |
| `totalVaulted()`        | Returns total ETH stored         |
| `totalDeposits()`       | Number of successful deposits    |
| `totalWithdrawals()`    | Number of successful withdrawals |
| `getWithdrawPerTxCap()` | Returns withdraw cap per tx      |
| `getBankCap()`          | Returns global deposit cap       |

---

## 🔒 Security Considerations

* No external calls in `deposit()`.
* `withdraw()` follows CEI and checks for transfer success.
* `receive()` and `fallback()` revert all direct ETH transfers.
* No reentrancy risk (no untrusted external calls before state updates).
* Gas-efficient counter updates with `unchecked`.

---

## 🧑‍💻 Author

**Paulo Srulevitch**
