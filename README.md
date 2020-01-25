# TezosKit

[![Build Status](https://travis-ci.org/keefertaylor/TezosKit.svg?branch=master)](https://travis-ci.org/keefertaylor/TezosKit)
[![codecov](https://codecov.io/gh/keefertaylor/TezosKit/branch/master/graph/badge.svg)](https://codecov.io/gh/keefertaylor/TezosKit)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/TezosKit.svg?style=flat)](http://cocoapods.org/pods/TezosKit)
[![License](https://img.shields.io/cocoapods/l/TezosKit.svg?style=flat)](http://cocoapods.org/pods/TezosKit)

TezosKit is a swift SDK that is compatible with the [Tezos Blockchain](https://tezos.com). TezosKit implements complex interaction with the blockchain, including:
* Performing preapplication for operations
* Automatically revealing accounts as needed
* Batching multiple operations

TezosKit provides native functionality to interact with a [Tezos node](docs/TezosNode.md) or [Conseil](docs/Conseil.md), an indexing service. TezosKit supports interaction with the chain via both closure based callbacks and Promises ([PromiseKit](https://github.com/mxcl/PromiseKit)) functionality.

TezosKit is compatible with both CocoaPods and Carthage. See the installation section below for specific instructions.

## QuickStart

### Wallets and Accounts
Accounts in Tezos are represented with `Wallet` objects.

To make a new wallet:
```swift
let wallet = Wallet()!
print("The wallet's mnemonic is \(wallet.mnemonic)")
```

To restore a wallet:
```swift
let mnemonic = ...
let wallet = Wallet(mnemonic: mnemonic)!
```

### Interacting with the Tezos Node
The `TezosNodeClient` class supports interacting with a Tezos Node. Interaction can be done with closure callbacks or Promises.

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

// PromiseKit Promises
tezosNodeClient.getBalance(address: "KT1BVAXZQUc4BGo3WTJ7UML6diVaEbe4bLZA").done { balance in
  print("The balance of the contract is \(balance.humanReadableRepresentation)")
} .catch { _ in
  print("Couldn't get balance.")
}
```

Learn more about interacting with a Tezos Node in the [Tezos Node Documentation](docs/TezosNode.md).

### Interacting with Conseil
The `ConseilClient` class supports interacting with a Conseil service. Interaction can be done with closure callbacks or Promises.

```swift
let conseilClent = ConseilClient(...)
let address = "tz1iZEKy4LaAjnTmn2RuGDf2iqdAQKnRi8kY"

// Closure completion handler
conseilClient.originatedAccounts(from: address) { result in
  switch result {
    case .success(let originatedAccounts):
      print("Originated Accounts:")
      print(result)
    case .failure(let error):
      print("Error fetching originated accounts: \(error)")
  }
}

// PromiseKit Promises
conseilClient.originatedAccounts(from: address).done { result in
  print("Originated Accounts:")
  print(result)
} .catch { error in
  print("Error fetching originated accounts: \(error)")
}
```

Learn more about interacting with a Conseil Service in the [Conseil Documentation](docs/Conseil.md).
## Advanced Usage
TezosKit is highly extensible for the needs of any individual project. Projects can customize RPCs and operations that are sent to the node. You can learn more about customizing TezosKit's behavior in the [Advanced Usage Documentation](docs/AdvancedFunctionality.md).
## Installation
You may use either Carthage or Cocoapods to depend on TezosKit.
### CocoaPods
TezosKit supports installation via CocoaPods. You can depened on TezosKit by adding the following to your Podfile:
```
pod "TezosKit"
```
### Carthage
If you use [Carthage](https://github.com/Carthage/Carthage) to manage your dependencies, simply add
TezosKit to your `Cartfile`:
```
github "keefertaylor/TezosKit"
```
If you use Carthage to build your dependencies, make sure you have added `Base58Swift.framework`, `BigInt.framework`, `MnemonicKit.framework`,  and `PromiseKit.framework`, `Sodium.framework` and `TezosCrypto.framework`, to the "_Linked Frameworks and Libraries_" section of your target, and have included them in your Carthage framework copying build phase.
## Bugs / Contributions
If you enounter bugs or missing features in TezosKit, please feel free to open a GitHub issue. You may want to check if the work you are suggesting is planned in [future work](docs/FutureWork.md).

Contributions and bug fixes are appreciated. Please open a PR for any missing or erroneous functionality for which you can contribute a fix.

To get started:
To get set up:
```shell
$ brew install xcodegen # if you don't already have it
$ xcodegen generate # Generate an XCode project from project.yml
$ open TezosKit.xcodeproj
```

## License
TezosKit is licensed under the permissive MIT licence.
## See Also
* [TezosCrypto](https://github.com/keefertaylor/TezosCrypto): A swift implementation of Tezos Cryptography
