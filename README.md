# 🔮 AI Trend Oracle

### Smart Contract for Predicting Trends Using AI Data (Fully On-Chain Logic)

---

## 📘 Overview

**AI Trend Oracle** is an Ethereum-based smart contract that simulates AI-driven market or data trend prediction — entirely on-chain, without external imports, constructors, or APIs.  
It produces pseudo-random "AI-like" predictions (Bullish 📈, Bearish 📉, or Neutral ⚖️) using blockchain parameters such as timestamp, block number, and randomness to simulate data analysis and inference.

This project demonstrates how **decentralized AI prediction models** can be designed and executed **autonomously on-chain**.

---

## 🌐 Deployed Contract

- **Network:** Ethereum Testnet (Remix / Local or Ganache)
- **Contract Address:** [`0xd9145CCE52D386f254917e481eB44e9943F39138`](https://sepolia.etherscan.io/address/0xd9145CCE52D386f254917e481eB44e9943F39138)

You can view or verify the contract on Etherscan (if deployed publicly) and interact using any Ethereum wallet or dApp interface.

---

## ⚙️ Features

✅ 100% on-chain logic — no imports, no constructors  
✅ Pseudo-random AI predictions generated each call  
✅ Zero external dependencies or user input  
✅ Transparent & verifiable using blockchain data  
✅ Lightweight and educational — perfect for Solidity beginners  

---

## 💻 Smart Contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AITrendOracle {
    string public currentTrend;
    uint256 public lastUpdated;
    uint256 private seed;

    // Simulate AI prediction using pseudo-random blockchain data
    function updateTrend() public {
        // Generate randomness using block data and previous seed
        seed = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, block.number, seed)));

        // Generate a random number between 0 and 2
        uint256 randomValue = seed % 3;

        if (randomValue == 0) {
            currentTrend = "Bullish 📈";
        } else if (randomValue == 1) {
            currentTrend = "Bearish 📉";
        } else {
            currentTrend = "Neutral ⚖️";
        }

        lastUpdated = block.timestamp;
    }

    // Return latest AI trend prediction
    function getTrend() public view returns (string memory) {
        return currentTrend;
    }
}
