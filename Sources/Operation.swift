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
 * Public protocol for operations.
 */
public protocol Operation {
  /** Retrieve a dictionary representing the operation's state. */
  var dictionaryRepresentation: [String: String] { get }
}

/**
 * An abstract super class representing an operation to perform on the blockchain.
 */
public class AbstractOperation: Operation {
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

  public var dictionaryRepresentation: [String : String] {
    var operation: [String: String] = [:]
    operation["kind"] = kind.rawValue
    operation["storage_limit"] = storageLimit.rpcRepresentation
    operation["gas_limit"] = gasLimit.rpcRepresentation
    operation["fee"] = fee.rpcRepresentation

    return operation
  }

  fileprivate init(from: String,
                   kind: OperationKind,
                   fee: TezosBalance = AbstractOperation.zeroTezosBalance,
                   gasLimit: TezosBalance = AbstractOperation.defaultLimitTezosBalance,
                   storageLimit: TezosBalance = AbstractOperation.defaultLimitTezosBalance ) {
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
public class SetDelegationOperation: AbstractOperation {
  public let delegate: String

  public override var dictionaryRepresentation: [String : String] {
    // TODO: Implement.
    return super.dictionaryRepresentation
  }

  public convenience init(from wallet: Wallet, to delegate: String) {
    self.init(from: wallet.address, to: delegate)
  }

  public init(from: String, to delegate: String) {
    self.delegate = delegate
    super.init(from: from, kind: .delegation)
  }
}
