# TezosKit

TezosKit is a Swift library that is compatible with the [Tezos Blockchain](https://tezos.com). TezosKit implements communication with the blockchain via the JSON API.

## Functionality

TezosKit provides first class support for the following RPCs:
* Getting account balances
* Getting data about the chain head
* Getting account delegates 
* Generating and restoring wallets 
* Sending transactions between accounts
* Sending multiple operations in a single request
* Setting a delegate
* (With more coming soon!)

The library is extensible allowing client code to easily create additional RPCs and signed operations, as required. 

TesosKit takes care of complex block chain interactions for you:
* Addresses are revealed automatically, if needed
* Sending multiple operations by passing them in an array

TezosKit is heavily inspired by functionality provided by other Tezos SDKs, such as [eztz](https://github.com/TezTech/eztz) or [TezosJ](https://github.com/LMilfont/TezosJ-plainjava).

## Installation

TezosKit is available via the Swift package manager.

### Build / Develop

To get started building and developing locally:

```console
# Clone TezosKit repo
$ git clone https://github.com/keefertaylor/TezosKit.git

# Build library
$ swift build

# Generate an xcode project
$ swift package generate-xcodeproj
generated: ./TezosKit.xcodeproj
$ open ./TezosKit.xcodeproj
```

### Depending on TezosKit

Depend on TezosKit by adding the following to your `Package.swift`:

```
.package(url: "https://github.com/keefertaylor/TezosKit.git", .branch("master")),
```

### LibSodium Errors

If you receive errors about missing Sodium headers, you need to install `libsodium`:

```console
$ brew install libsodium
```

## Getting Started

### Create a Network Client

```swift
let publicNodeURL = URL(string: "https://rpc.tezrpc.me")!
let tezosClient = TezosClient(remoteNodeURL: publicNodeURL)
```

### Retrieve Data About the Blockchain

```swift
tezosClient.getHead() { (result: [String: Any]?, error: Error?) in
  guard let result = result,
        let metadata: = result["metadata"] as? [String : Any],
        let baker = metadata["baker"]  else {
    return
  }
  print("Baker of the block at the head of the chain is \(baker)")
}
```

### Retrieve Data About a Contract

```swift
let address = "KT1BVAXZQUc4BGo3WTJ7UML6diVaEbe4bLZA" // http://tezos.community
tezosClient.getBalance(address: address) { (balance: TezosBalance?, error: Error?) in
  guard let balance = balance else {
    return
  }
  print("Balance of \(address) is \(balance.humanReadableRepresentation)")
}
```

### Create a Wallet

```swift
let wallet = Wallet()
print("New wallet mnemonic is: \(wallet.mnemonic)")
```

### Send a Transaction

```swift
let wallet = Wallet()
let sendAmount = TezosBalance(balance: 1.0)!
let recipientAddress = ...
tezosClient.send(amount: sendAmount,
                 to recipientAddress: recipientAddress,
                 from address: wallet.address,
                 secretKey: wallet.secretKey) { (txHash, txError) in 
  print("Transaction sent. See: https://tzscan.io/\(txHash!)")
}
```

### Send Multiple Transactions at Once

Here's an example of how you can send multiple transactions at once. You 
can easily send Jim and Bob some XTZ in one call:

```swift
let myWallet: Wallet = ...
let jimsAddress: String = tz1...
let bobsAddress: String = tz1...

let amountToSend = TezosBalance("2")!

let sendToJimOperation = TransactionOperation(amount: amountToSend,
				    						  source: myWallet,
											  destination: jimsAddress)
let sendToBobOperation = TransactionOperation(amount: amountToSend,
											  source: myWallet,
											  destination: bobsAddress)

let operations = [ sendToJimOperation, sendToBobOperation ]
tezosClient.forgeSignPreapplyAndInjectOperations(operations: operations,
												 source: myWallet.address,
												 keys: myWallet.keys) { (txHash, error) in
  print("Sent Jim and Bob some XTZ! See: https://tzscan.io/\(txHash!)")
}
```

### Set a Delegate

```swift
let wallet = ...
let originatedAccountAddress = <Some Account Managed By Wallet>
let delegateAddress = ...
tezosClient.delegate(from: originatedAccountAddress,
                     to: delegateAddress,
					 keys: wallet.keys) { (txHash, txError) in 
  print("Delegate for \(originatedAccountAddress) set to \(delegateAddress). See: https://tzscan.io/\(txHash!)")
}
```

## Contributing

I am happy to accept pull requests. 

## Donations

Greatly appreciated.

* Bitcoin: 1CdPoF9cvw3YEiuRCHxdsGpvb5tSUYBBo 
* Bitcoin Cash: qqpr9are9gzs5r0q7hy3gdehj3w074pyqsrhpdmxg6 
* Tezos: tz1SNXT8yZCwTss2YcoFi3qbXvTZiCojx833

## License

MIT
