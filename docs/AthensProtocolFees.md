# Fees for Athens Protocol (Protocol 004)

Fees for operations in the Athens protocol. All fees are in mutez. These fees are minimums and should be generated with:
```fees >= (minimal_fees + minimal_nanotez_per_byte * size + minimal_nanotez_per_gas_unit * gas)```

For details, see: https://tezos.stackexchange.com/questions/436/how-does-tezos-client-compute-a-transaction-fee

**Reveals**
- storage_limit: 0
- gas_limit: 10000
- fee: 1270

**Delegations**
- storage_limit: 0 
- gas_limit: 10000
- fee: 1258

**Originations**
- storage_limit: 277
- gas_limit: 10100
- fee: 1266

* An additional 257000 mutez is burned from the source account.

**Transfers to Empty Implicit Account**
- storage_limit: 277
- gas_limit: 10300
- fee: 1285

* An additional 257000 mutez is burned from the source account.

**Emptying an Implicit Account**
- gas_limit: 10600
- storage_limit: 0
- fee: 1313

**All other transfers**
- storage_limit: 0
- gas_limit: 10300
- fee: 1285
