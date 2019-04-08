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

*** TODO *** Write about how to create a custom operation. Consider whether centralizing `requiresReveal` is conducive to what you'd like to do. Does this mean you can drop off `Abstract operation`?

### Injecting an Operation

`TezosNodeClient` provides a method which lets you inject a custom operation. Injecting a custom operation in the node is easy:

```swift
let wallet = Wallet(...)
let tezosNodeClient = TezosNodeClient(...)
let customOperation = MyCustomOperation(...)

tezosNodeClient.forgeSignPreapplyAndInject(
  customOperation
  source: wallet.address,
  keys: wallet.keys
) { result in 
  // Handle result hash
}

```

Like all `TezosNodeClient` methods, injection is supported with closure based callbacks or with Promises.