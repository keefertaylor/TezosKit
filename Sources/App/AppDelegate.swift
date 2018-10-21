import UIKit
import CKMnemonic
import Sodium
import Base58String

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Run some basic tests.
    // TODO: Refactor these to be proper unit tests.
    testWalletGeneration()
    testChainRPCs()
    testAddressRPCs()

    return true
  }

  private func testWalletGeneration() {
    // Params for a wallet. This wallet is never originated and should *NOT* be used as the secret
    // key will live in github.
    let expectedPublicKey = "edpku9ZF6UUAEo1AL3NWy1oxHLL6AfQcGYwA5hFKrEKVHMT3Xx889A"
    let expectedSecretKey =
        "edskS4pbuA7rwMjsZGmHU18aMP96VmjegxBzwMZs3DrcXHcMV7VyfQLkD5pqEE84wAMHzi8oVZF6wbgxv3FKzg7cLqzURjaXUp"
    let expectedPublicKeyHash = "tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw"
    let expectedMnemonic =
        "soccer click number muscle police corn couch bitter gorilla camp camera shove expire praise pill"

    // Create a wallet.
    guard let wallet = Wallet(mnemonic: expectedMnemonic) else {
      print("Error creating wallet :(");
      return
    }

    print("Expected Public Key: " + expectedPublicKey)
    print("Actual Public Key  : " + wallet.publicKey)
    print("")

    print("Expected Private Key: " + expectedSecretKey)
    print("Actual Private Key  : " + wallet.secretKey)
    print("")

    print("Expected Hash Key: " + expectedPublicKeyHash)
    print("Actual Hash Key  : " + wallet.address)
    print("")

    print("Expected mnemonic: " + expectedMnemonic)
    print("Actual mnemonic  : " + wallet.mnemonic)
    print("")
  }

  private func testChainRPCs() {
    let publicNodeURL = URL(string: "https://rpc.tezrpc.me")!
    let tezosClient = TezosClient(remoteNodeURL: publicNodeURL)

    tezosClient.getHead() { (result: [String: Any]?, error: Error?) in
      guard let result = result,
            let metadata: [String: Any] = result["metadata"] as? [String : Any] else {
        return
      }
      print("Got Head Chain ID is: " + String(describing: result["chain_id"]!))
      print("Got Head. Baker is: " + String(describing: metadata["baker"]!))
    }

    tezosClient.getHeadHash() { (hash: String?, error: Error?) in
      print("Got hash at head to be: " + hash!)
    }
  }

  private func testAddressRPCs() {
    let publicNodeURL = URL(string: "https://rpc.tezrpc.me")!
    let tezosClient = TezosClient(remoteNodeURL: publicNodeURL)

    // Originated account for Tezos.Community.
    // See: KT1BVAXZQUc4BGo3WTJ7UML6diVaEbe4bLZA
    let address = "KT1BVAXZQUc4BGo3WTJ7UML6diVaEbe4bLZA"
    tezosClient.getBalance(address: address) { (result: TezosBalance?, error: Error?) in
      print("Got Balance (Addr):  " + result!.humanReadableRepresentation)
    }
    tezosClient.getDelegate(address: address) { (delegate: String?, error: Error?) in
      print("Got delegate (Addr): " + delegate!)
    }
    tezosClient.getAddressCounter(address: address) { (counter: String?, error: Error?) in
      print("Got counter: " + counter!)
    }
    tezosClient.getAddressManagerKey(address: address) { (managerKey: [String: Any]?, error: Error?) in
      print("Got address manager key: \(managerKey!)")
    }
  }
}


