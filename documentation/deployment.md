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

Total signers: 10

- MarketDeployer: hardware cold wallet
- CircuitBreaker: GnosisSafe, 1 signer required
- Timelock owner: GnosisSafe Governance, 4 signers required
- Comptroller: GnosisSafe Governance, 4 signers required
- Whitelist owner: GnosisSafe Governance, 4 signers required
- Treasury: GnosisSafe Treasury, 6 signers required

---

#### Core deployment

- Deploy HyperlendWhitelist and set owner to COMPTROLLER_ADDRESS. Only whitelisted deployers can create new markets.
- Deploy HyperlendPairRegistry with owner and initialDeployers set to COMPTROLLER_ADDRESS, add marketDeployer wallet as initialDeployers too.
- Deploy HyperlendPairDeployer contract. 
- Set HyperlendPairDeployer address as deployer in HyperlendPairRegistry.

---

#### Market deployment

- Deploy rate contracts, LinearInterestRate.sol and VariableInterestRate.sol
- Deploy oracle contract (or use existing oracle).
- Call HyperlendPairDeployer.deploy()


