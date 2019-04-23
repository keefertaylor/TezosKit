# Operations

Operations are an advanced topic which most users of TezosKit will not need to know about.

Any injectable operation in the Tezos blockchain is represented by an object that inherits from `AbstractOperation`, which conforms to the `Operation` protocol. 

## Supported Operations

Common operations on Tezos are supported out of the box on TezosKit. These operations include:
* Sending Tezzies
* Calling Smart Contracts
* Delegating the Balance of an Account
* Originating a new Account

Users of these common operations will never have to work with `Operation` objects directly and can instead call associated methdos on `TezosNodeClient`.

## Custom Operations

Users of TezosKit can create and inject custom operations. Creating a custom operation requires some wiring, but is fairly straightforward.

### Creating an Operation

TezosKit can inject any operation which conforms to the `Operation` protocol. Users can wire up custom operations. In most cases, you'll want to subclass `AbstractOperation` to get baseline functionality.

The `Operation` protocol requires three properties to be implemented: 
* `requiresReveal`: If `true` then TezosKit will automatically add a reveal operation any time this operation is applied to an unrevealed account.
* `defaultFees`: An `OperationFees` object which represents the default fees for the operation. 
* `dictionaryRepresentation`: A representation of the dictionary in a `Dictionary`.

Note that `dictionaryRepresentation` contains only the values represented by the operation. Values like `signature` and `branch` are not required. For instance, a `dictionaryRepresentation` of a `TransactionOperation` looks like:
```swift
[
  "source": "tz1...",
  "destination": "tz1...",
  "amount": "123",
  "kind": "transaction",
  "fee": "1",
  "gas_limit": "1",
  "storage_limit": "1"
]
```

### Injecting an Operation

`TezosNodeClient` provides a method which lets you inject a custom operation. Injecting a custom operation in the node is easy:

```swift
let wallet = Wallet(...)
let tezosNodeClient = TezosNodeClient(...)
let customOperation = MyCustomOperation(...)

tezosNodeClient.forgeSignPreapplyAndInject(
  customOperation,
  source: wallet.address,
  keys: wallet.keys
) { result in 
  // Handle result hash
}

```

Or if you'd like to inject multiple operations, pass them as an array. Operations are processed in the order they are inserted into the array:

```swift
let wallet = Wallet(...)
let tezosNodeClient = TezosNodeClient(...)
let transactionOperation = TransactionOperation(...)
let customOperation = MyCustomOperation(...)

tezosNodeClient.forgeSignPreapplyAndInject(
  [customOperation, transactionOperation],
  source: wallet.address,
  keys: wallet.keys
) { result in 
  // Handle result hash
}

```

Like all `TezosNodeClient` methods, injection of single and multiple operations is supported with closure based callbacks or with Promises.