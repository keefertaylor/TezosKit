import Foundation

/**
 * An enum representing all supported operation types.
 */
public enum OperationKind: String {
  case delegation = "delegation"
}

/**
 * An abstract super class representing an operation to perform on the blockchain.
 */
public class Operation {
  public let from: String
  public let kind: OperationKind
  public let fee: String
  public let gasLimit: String
  public let storageLimit: String

  fileprivate init(from: String, kind: OperationKind, fee: String, gasLimit: String, storageLimit: String) {
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
    super.init(from: from, kind: .delegation, fee: "0", gasLimit: "0", storageLimit: "0")
  }
}
