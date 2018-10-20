import Foundation

/**
 * An enum representing all supported operation types.
 */
public enum OperationKind: String {
  case delegation = "delegation"
  case transaction = "transaction"
  case origination = "origination"
  case activateAccount = "activate_account"
}

/**
 * An abstract super class representing an operation to perform on the blockchain.
 */
public class Operation {
  /** A Tezos balance representing 0. */
  fileprivate static let zeroTezosBalance = TezosBalance(balance: "0")

  /** A Tezos balance that is the default used for gas and storage limits. */
  fileprivate static let defaultLimitTezosBalance = TezosBalance(balance: "10000")

  public let from: String
  public let kind: OperationKind
  public let fee: TezosBalance
  public let gasLimit: TezosBalance
  public let storageLimit: TezosBalance
  public var requiresReveal: Bool {
    switch self.kind {
      case .delegation, .transaction, .origination:
        return true
      case .activateAccount:
        return false
    }
  }

  fileprivate init(from: String,
                   kind: OperationKind,
                   fee: TezosBalance = Operation.zeroTezosBalance,
                   gasLimit: TezosBalance = Operation.defaultLimitTezosBalance,
                   storageLimit: TezosBalance = Operation.defaultLimitTezosBalance ) {
    self.from = from
    self.kind = kind
    self.fee = fee
    self.gasLimit = gasLimit
    self.storageLimit = storageLimit
  }
}

/**
 * An operation to set a delegate for an address.
 */
public class SetDelegationOperation: Operation {
  public let delegate: String

  public convenience init(from wallet: Wallet, to delegate: String) {
    self.init(from: wallet.address, to: delegate)
  }

  public init(from: String, to delegate: String) {
    self.delegate = delegate
    super.init(from: from, kind: .delegation)
  }
}
