# HyperLend

<br>

### Introduction to HyperLend

HyperLend is a lending platform (based on [FraxLend](https://docs.frax.finance/fraxlend/fraxlend-overview)) that allows users to create an isolated market between a pair of ERC-20 tokens. 

HyperLend adheres to the EIP-4626: Tokenized Vault Standard, lenders are able to deposit ERC-20 assets into the pair and receive yield-bearing hTokens.  

***[Documentation](https://docs.hyperlend.finance/)***

## Overview

![pairOverview](./documentation/_images/pairOverview.jpg)

<br>
<br>

### Building and Testing

- First copy `.env.example` to `.env` and fill in archival node URLs as well as a mnemonic (hardhat only)
- To download needed modules run `npm install`
- This repository contains scripts to compile using both Hardhat and Foundry
- You will need to [install foundry](https://book.getfoundry.sh/getting-started/installation)
- Install foundry submodules `git submodule init && git submodule update`

Compilation

- `forge build`
- `npx hardhat compile`

<br>
<br>

### License
Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
