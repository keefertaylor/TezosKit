// Copyright Keefer Taylor, 2018

import TezosKit

let tezosNodeClient = TezosNodeClient()
let wallet = Wallet()!

tezosNodeClient.getHeadHash { headHash, error in
  guard let headHash = headHash,
    error == nil else {
    print("Couldn't fetch head :(")
    if let error = error {
      print("Error: \(error)")
    }
    return
  }
  print("The hash of the head block was \(headHash)")
}

tezosNodeClient.getBalance(wallet: wallet) { balance, error in
  guard let balance = balance,
    error == nil else {
    print("Couldn't fetch balance :(")
    if let error = error {
      print("Error: \(error)")
    }
    return
  }
  print("The balance of \(wallet.address) was \(balance.humanReadableRepresentation)")
}
