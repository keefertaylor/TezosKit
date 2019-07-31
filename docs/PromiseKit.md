# PromiseKit

The core of TezosKit provides closure style callbacks.

An extension of the library provides [PromiseKit](https://github.com/mxcl/PromiseKit) functionality. In CocoaPods, PromiseKit is split into a separate module. In Carthage, all code is delivered as a single module.

### Using Promises

In general, any call you can make on a `TezosNodeClient` or `ConseilClient` can also be done with promises.

For instance, the following closure style callbacks:

```swift
let tezosNodeClient = TezosClient()

// Closure completion handler
tezosNodeClient.getBalance(address: "KT1BVAXZQUc4BGo3WTJ7UML6diVaEbe4bLZA") { result in
  switch result {
  case .success(let balance):
    print("The balance of the contract is \(balance.humanReadableRepresentation)")
  case .failure(let error):
    print("Error getting balance: \(error)")
  }
}
```

Are equivalent to:

```swift
let tezosNodeClient = TezosClient()

// PromiseKit Promises
tezosNodeClient.getBalance(address: "KT1BVAXZQUc4BGo3WTJ7UML6diVaEbe4bLZA").done { balance in
  print("The balance of the contract is \(balance.humanReadableRepresentation)")
} .catch { _ in
  print("Couldn't get balance.")
}
```
