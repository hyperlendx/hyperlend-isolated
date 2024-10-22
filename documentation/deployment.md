### Deployment documentation

---

NO SUPPORT FOR REBASING and FEE-ON-TRANSFER tokens

---

Privileged addresses

| Name      | Contract | Description |
| ----------- | ----------- | ----------- |
| whitelisted deployers | Whitelist  | can deploy new markets |
| owner | HyperlendPairRegistry | can register new pairs and change deployers | 
| whitelisted deployers | HyperlendPairRegistry | can register new pairs | 
| owner | HyperlendPairDeployer | can change deployment code for pairs, whitelisted swappers, timelock, registry, comptroller, circuit breaker and whitelist addresses|
| circuitBreaker | HyperlendPairDeployer | can call globalPause which pauses the pair contract |
| circuitBreakerAddress, owner, timelockAddress | HyperlendPairAccessControl | can pause markets/borrow/deposit/repay/withdraw/liquidate/interest in pairs | 
| timelockAddress, owner/comptroller | HyperlendPairAccessControl | can unpause, set borrow/deposit limit, pause withdraw/repay/liquidate/interest |
| timelock | HyperlendPairAccessControl | can set new circuitBreakerAddress |
| timelock | HyperlendPair | can revokeInterestAccessControl, revokeLiquidateAccessControl, revokeWithdrawAccessControl, revokeRepayAccessControl, revokeDepositAccessControl, revokeBorrowAccessControl, changeFee, setLiquidationFees, revokeLiquidationFeeSetter, setRateContract, revokeRateContractSetter, setMaxLTV, revokeMaxLTVSetter, setOracle, revokeOracleInfoSetter |
| owner | HyperlendPair | can whitelist swappers, withdrawFees |

---

Governance config:

Total signers: 8

- MarketDeployer: Ledger cold wallet
- CircuitBreaker: GnosisSafe, 1 signer required
- Timelock owner: GnosisSafe Governance, 4 signers required
- Comptroller: GnosisSafe Governance, 4 signers required
- Whitelist owner: GnosisSafe Governance, 4 signers required
- Treasury: GnosisSafe Treasury, 5 of 8

fbsloXBT: 3
0xnessus: 2
sventure5: 1
maiviuss: 1
tee_hary: 1

Arbitrum addresses:
    - GnosisSafe CircuitBreaker: [arb1:0x03C734090be6C151fbF1cc90ed1Ac4ff35bEBEc0](https://app.safe.global/home?safe=arb1:0x03C734090be6C151fbF1cc90ed1Ac4ff35bEBEc0)
    - GnosisSafe Governance: [arb1:0x4b3b779b2E9816078cD4cD754B9dD2AB02Ea5558](https://app.safe.global/home?safe=arb1:0x4b3b779b2E9816078cD4cD754B9dD2AB02Ea5558)
    - GnosisSafe Treasury: [arb1:0x76A99A03c44eEAe3f596017BBA48647A69A429c9](https://app.safe.global/home?safe=arb1:0x76A99A03c44eEAe3f596017BBA48647A69A429c9)

---

#### Core deployment

Deploy HyperlendWhitelist and set owner to COMPTROLLER_ADDRESS. Only whitelisted deployers can create new markets.
Deploy HyperlendPairRegistry with owner and initialDeployers set to COMPTROLLER_ADDRESS, add marketDeployer wallet as initialDeployers too.

Deploy HyperlendPairDeployer contract. 

Set HyperlendPairDeployer address as deployer in HyperlendPairRegistry.

---

#### Market deployment

Deploy rate contracts, LinearInterestRate.sol and VariableInterestRate.sol

Deploy oracle contract (or use existing oracle).

Call HyperlendPairDeployer.deploy()


