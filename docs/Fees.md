# Fees
Fees are an advanced topic which most users of TezosKit will not need to know about.

Every `Operation` contains an `OperationFees` struct which represents a set of fees (fee, gas limit, storage limit) that will be applied when it is injected into the network. 

All calls on `TezosNodeClient` that injects an operation on the network provide an opportunity to provide a custom fee structure. If no fee structure is provided, the default fees are used for the operation.

### Defaults

TezosNodeClient will provide default fees for the `TezosProtocol` version that is provided at initialization time. A `DefaultFeeProvider` object provides fees for a given operation type and `TezosProtocol` version. 

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
