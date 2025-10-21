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

