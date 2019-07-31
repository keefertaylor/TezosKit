# Tezos Node Client
## Introduction
A Tezos Node is the main entry point to the Tezos Network. The `TezosNodeClient` class in TezosKit allows client applications to interact with the node via the JSON RPC API. 

The `TezosNodeClient` API provides affordances to examine the state of the Tezos blockchain as well as to inject operations into the chain.

The `TezosNodeClient` functionality supports both `Result` style completion blocks or a promises API ([via PromiseKit](https://github.com/mxcl/PromiseKit))

## Getting Started
The TezosNodeClient supports a wide set of functionality, which includes:
* Getting account balances
* Getting data about the chain head
* Getting account delegates 
* Generating and restoring wallets 
* Sending transactions between accounts
* Sending multiple operations in a single request
* Setting / clearing delegates
* Registering as a delegate
* Originating accounts
* Examining upgrade votes
* Invoking Smart Contracts
* Examing smart contract storage or big maps

### TezosNodeClient Client
Create a `TezosNodeClient` that will connect to a remote Tezos Node service.
```swift
let publicNodeURL = URL(string: "https://rpc.tezrpc.me")!
let tezosNodeClient = TezosNodeClient(remoteNodeURL: publicNodeURL)
```

#### Optional Parameters

By default, `TezosNodeClient` provides sane defaults for most users. Some parameters in the initializer can be configured for extra functionality:

|Parameter | Type | Default | Description |
|---|---|---|---|
|`remoteNodeURL` | `URL` | https://rpc.tezrpc.me | The URL for the remote Tezos Node. |
|`tezosProtocol` | `TezosProtocol` | `.athens` | An enum describing the protocol running on the remote node |
|`forgingPolicy` | `ForgingPolicy` | `.remote` | A policy which dictates how operations are forged |
|`urlSession` | `URLSession` | `URLSession.Shared` | A URL session to use for network requests |
|`callbackQueue` | `DispatchQueue` | `DispatchQueue.main` | A queue to execute callbacks on. |

### Wallets
Every account on the Tezos Blockchain is represented by a `Wallet` object.  By default, wallets are created with an:
- Address: The wallet's address on the blockchain. This is either a tz1, tz2, tz3 or KT1 address
- Keys: A set of keys which manage the Accounts address.

Keys are decoupled from a wallets address because originated accounts are managed by the same set of keys as the implicit account which manages it.

In the case of generating a wallet, the Mnemonic field will also be generated. 

#### Creating a Wallet
Wallets are generated with a mnemonic and a passphrase.

With no passphrase:
```swift
let wallet = Wallet()!
print("Your new wallet's mnemonic is \(wallet.mnemonic!)")
```

To attach a passphrase:
```swift
let wallet = Wallet(passphrase: "TREZOR")!
print("Your new wallet's mnemonic is \(wallet.mnemonic!)")
```
#### Restoring a Wallet
You can restore a wallet from either a secret key or by providing the original mnemonic and passphrase.

##### Mnenomic Based Restoration

Without a passphrase:
```swift
let mnemonic = ...
let wallet = Wallet(mnemonic: mnemonic)
```

With a passphrase:
```swift
let mnemonic = ...
let passphrase = ...
let wallet = Wallet(mnemonic: mnemonc, passphrase: passphrase)
```

##### Secret Key Based Restoration

You can restore a wallet from a secret key. Secret keys are accessible from an already instantiated wallet via the `secret` property in the `keys` property.

```swift
let myWallet = Wallet()

let secretKey = myWallet.keys.secret
let newWallet = Wallet(secretKey: secretKey)
```

### SignatureProvider
The `SignatureProvider` protocol encompasses objects which can sign transactions. All `Wallet` objects in TezosKit are `SignatureProviders`.

#### Hierarchical Derivation Wallets
TezosKit does not yet support hierarchical derivation for wallets. This functionality will be delivered in a future update.
#### Secure Enclave Wallets
TezosKit does not yet support wallets that utilize the secure enclave to sign transactions. This functionality will be delivered in a future update.

### Making Calls to the Network

Using the primitives provided by the Wallet and the TezosClientNode, TezosKit can make many calls to the network to determine the state of the blockchain.

#### Retrieve Data About the Blockchain

```swift
tezosNodeClient.getHead() { result in
  switch result {
  case .success(let result):
    guard let metadata: = result["metadata"] as? [String : Any],
          let baker = metadata["baker"]  else {
      print("Unexpected format")
      return
    }
    print("Baker of the block at the head of the chain is \(baker)")
  case .failure(let error):
    print("Error getting result: \(error)")
  }
```

#### Retrieve Data About a Contract

```swift
let address = "KT1BVAXZQUc4BGo3WTJ7UML6diVaEbe4bLZA" // http://tezos.community
tezosNodeClient.getBalance(address: address) { result in
  switch result {
  case .success(let balance):
    print("Balance of \(address) is \(balance.humanReadableRepresentation)")
  case .failure(let error):
    print("Error getting result: \(error)")
  }
}
```

#### Send a Transaction

```swift
let wallet = Wallet()
let sendAmount = Tez(1.0)!
let recipientAddress = ...
tezosNodeClient.send(
  amount: sendAmount,
  to recipientAddress: recipientAddress,
  from address: wallet.address,
  secretKey: wallet.secretKey
) { (txHash, txError) in 
  print("Transaction sent. See: https://tzscan.io/\(txHash!)")
}
```

#### Send Multiple Transactions at Once

Here's an example of how you can send multiple transactions at once. You 
can easily send Jim and Bob some XTZ in one call:

```swift
let myWallet: Wallet = ...
let jimsAddress: String = tz1...
let bobsAddress: String = tz1...

let amountToSend = Tez("2")!

let sendToJimOperation = TransactionOperation(amount: amountToSend,
                                              source: myWallet,
                                              destination: jimsAddress)
let sendToBobOperation = TransactionOperation(amount: amountToSend,
                                              source: myWallet,
                                              destination: bobsAddress)

let operations = [ sendToJimOperation, sendToBobOperation ]
tezosNodeClient.forgeSignPreapplyAndInjectOperations(
  operations: operations,
  source: myWallet.address,
  keys: myWallet.keys
) { result in
  guard case let .success(txHash) = result else {
    return
  }
  print("Sent Jim and Bob some XTZ! See: https://tzscan.io/\(txHash!)")
}
```

#### Set a Delegate

```swift
let wallet = ...
let originatedAccountAddress = <Some Account Managed By Wallet>
let delegateAddress = ...
tezosNodeClient.delegate(
  from: originatedAccountAddress,
  to: delegateAddress,
  keys: wallet.keys
) { result in
  guard case let .success(txHash) = result else {
    return
  }
  print("Delegate for \(originatedAccountAddress) set to \(delegateAddress).")
  print("See: https://tzscan.io/\(txHash!)")
}

```

#### Call a Smart Contract

Assuming a smart contract takes a single string as an argument:

```swift
let operationFees = OperationFees(fee: Tez(1), gasLimit: 733_732, storageLimit: 0)
let parameter =
  RightMichelsonParameter(
    arg: LeftMichelsonParameter(
      arg: PairMichelsonParameter(
        left: IntMichelsonParameter(int: 1),
        right: StringMichelsonParameter(string: .testExpirationTimestamp)
      )
    )
  )

tezosNodeClient.send(
  contract: Wallet.dexterExchangeContract,
  amount: Tez(1.0),
  parameter: parameter,
  source: Wallet.testWallet.address,
  signatureProvider: Wallet.testWallet,
  operationFees: operationFees
) { result in
  guard case let .success(txHash) = result else {
    return
  }
  print("Called a smart contract. See https://tzscan.io/\(txHash!)")
}
```

### Introspect Contract Storage
```
self.nodeClient.getContractStorage(address: Wallet.tokenContract) { result in
  ...
}
```

### Introspect A Big Map
```
let parameter = StringMichelsonParameter(string: "tz1RYq8wjcCbRZykY7XH15WPkzK7TWwPvJJt")
self.nodeClient.getBigMapValue(
  address: "KT1BVAXZQUc4BGo3WTJ7UML6diVaEbe4bLZA",
  key: parameter,
  type: .address
) { result in
  ...
}
```

### PromiseKit Variants

All RPCs can also be done with Promises. For instance, to retrieve a balance: 
```
nodeClient.getBalance(address: "KT1BVAXZQUc4BGo3WTJ7UML6diVaEbe4bLZA").done { result in
  let balance = Double(result.humanReadableRepresentation)!
  print("The balance of the contract is \(balance)")
} .catch { _ in
  print("Couldn't get balance.")
}
```

### Multiple Operations

Operations can be batched and applied in a single injection. Simply place the operations in an array and pass them to the `TezosNodeClient`.

```swift
let wallet = Wallet(...)
let nodeClient = TezosNodeClient(...)
let txOp = TransactionOperation(...)
let delegationOp = DelegationOperation(...)

let operationArray = [ txOp, delegationOp ]

nodeClient.forgeSignPreapplyAndInject(
  operationArray,
  source: wallet.address,
  keys: wallet.keys,
) { result in 
  // result is a hash representing the injected operations.
}
```

## Preapplication

All calls that inject an operation will run a preapply operation to ensure operation validity. A future update will make this functionality optional.

## Reveals

The Tezos blockchain requires a reveal operation to be performed before an operation will be accepted. TezosKit automatically adds a reveal operation when required. 

## Forging

All forging in TezosKit is done remotely. A future update will support local forging. 

## Custom RPC API
`TezosNodeClient` will dutifully send along any RPC that subclasses `RPC`. You can subclass this object to create custom queries. Read more about this in the [Networking documentation](Networking.md).

## Custom Operations API
`TezosNodeClient` can inject any operation which conforms to the `Operation` protocol. Read more about this in the [Operations documentation](Operations.md).

