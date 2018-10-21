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

  public let source: String
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
    operation["source"] = source

    return operation
  }

  fileprivate init(source: String,
                   kind: OperationKind,
                   fee: TezosBalance = AbstractOperation.zeroTezosBalance,
                   gasLimit: TezosBalance = AbstractOperation.defaultLimitTezosBalance,
                   storageLimit: TezosBalance = AbstractOperation.defaultLimitTezosBalance ) {
    self.source = source
    self.kind = kind
    self.fee = fee
    self.gasLimit = gasLimit
    self.storageLimit = storageLimit
  }
}

/**
 * An operation to send an amount of XTZ.
 */
public class TransactionOperation: AbstractOperation {
  private let amount: TezosBalance
  private let destination: String

  public override var dictionaryRepresentation: [String : String] {
    var operation = super.dictionaryRepresentation
    operation["amount"] = amount.rpcRepresentation
    operation["destination"] = destination

    return operation
  }

  public convenience init(amount: TezosBalance, from wallet: Wallet, to destination: String) {
    self.init(amount: amount, source: wallet.address, destination: destination)
  }

  public init(amount: TezosBalance, source: String, destination: String) {
    self.amount = amount
    self.destination = destination

    super.init(source: source, kind: .transaction)
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
    self.init(source: wallet.address, to: delegate)
  }

  public init(source: String, to delegate: String) {
    self.delegate = delegate
    super.init(source: source, kind: .delegation)
  }
}
