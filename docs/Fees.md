# Fees
Fees are an advanced topic which most users of TezosKit will not need to know about.

Every `Operation` contains an `OperationFees` struct which represents a set of fees (fee, gas limit, storage limit) that will be applied when it is injected into the network. 

All calls on `TezosNodeClient` that injects an operation on the network provide an opportunity to provide a custom fee structure. If no fee structure is provided, the default fees are used for the operation.

### Defaults

Each `Operation` object has a default fee that is used when injecting the fee onto the blockchain if no other fee is proved. These default fees are taken from the recommended fees for protocol version 3, as documented in [eztz](https://github.com/TezTech/eztz/blob/master/PROTO_003_FEES.md).

### Custom Fees

#### TezosNodeClient Operations

Overriding the fees on an operation supported by the TezosNodeClient is easy. Simply pass a value for the fees parameter:
```swift
// Create a node client
let tezosNodeClient = TezosNodeClient(...)

// Create a custom OperationFees object
let customOperationFees = OperationFees(...)

// Inject an operation with a custom fee.
tezsosNodeClient.delegate(
  from: ...
  to: ...
  keys: ...
  operationFees: customOperationFees,
) { result in 
  // Handle callback
}
```

#### Custom Operations

If you are writing custom `Operation` objects, then the default fees for that operation are provided by your implementation. See [Operations](Operations.md) for more details.

### Estimated Gas Limit

The Tezos network supports estimating the Gas used in an operation. This functionality will be supported in TezosKit in a future update. 
