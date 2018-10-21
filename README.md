# TezosKit

TezosKit is a Swift library that is compatible with the [Tezos Blockchain](https://tezos.com). TezosKit implements communication with the blockchain via the JSON API.

Currently, TezosKit supports:
* Getting account balances
* Getting data about the chain head
* Getting account delegates 
* Generating and restoring wallets 
* Sending transactions between accounts

TezosKit aims to support a greater array of RPCs in the future, similar to [eztz](https://github.com/TezTech/eztz) or [TezosJ](https://github.com/LMilfont/TezosJ-plainjava).

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
let sendAmount = TezosBalance(balance: 1.0)
let recipientAddress = ...
tezosClient.send(amount: sendAmount,
                 to recipientAddress: recipientAddress,
                 from address: wallet.address,
                 secretKey: wallet.secretKey) { (txHash?, txError?) in 
  guard let txHash = txHash else {
    return
  }
  print("Transaction sent. See: https://tzscan.io/\(txHash)")
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
