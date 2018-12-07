// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An abstract super class representing an operation to perform on the blockchain. Common parameters
 * across operations and default parameter values are provided by the abstract class's
 * implementation.
 */
public class AbstractOperation: Operation {
  /** A Tezos balance representing 0. */
  public static let zeroTezosBalance = TezosBalance(balance: "0")!

  /** A Tezos balance that is the default used for gas and storage limits. */
  public static let defaultLimitTezosBalance = TezosBalance(balance: "10000")!

  public let source: String
  public let kind: OperationKind
  public let fee: TezosBalance
  public let gasLimit: TezosBalance
  public let storageLimit: TezosBalance
  public var requiresReveal: Bool {
    switch kind {
    case .delegation, .transaction, .origination:
      return true
    case .activateAccount, .reveal:
      return false
    }
  }

  public var dictionaryRepresentation: [String: Any] {
    var operation: [String: String] = [:]
    operation["kind"] = kind.rawValue

    let fee = TezosBalance(balance: 0.001272)
    let storageLimit = TezosBalance(balance: 0.000257)
    let gasLimit = TezosBalance(balance: 0.010100)

    operation["storage_limit"] = "0"
    operation["gas_limit"] =  "23305"
    operation["fee"] =  "1000000"
    operation["source"] = source

    return operation
  }

  public init(source: String,
              kind: OperationKind,
              fee: TezosBalance = AbstractOperation.zeroTezosBalance,
              gasLimit: TezosBalance = AbstractOperation.defaultLimitTezosBalance,
              storageLimit: TezosBalance = AbstractOperation.defaultLimitTezosBalance) {
    self.source = source
    self.kind = kind
    self.fee = fee
    self.gasLimit = gasLimit
    self.storageLimit = storageLimit
  }
}
