// Copyright Keefer Taylor, 2018

import Foundation

/// An object encapsulating the payment for an operation on the blockchain.
public struct OperationFees {
  public let fee: Tez
  public let gasLimit: Int
  public let storageLimit: Int

  /// A zero-ed fees object.
  internal static let zeroFees = OperationFees(fee: .zeroBalance, gasLimit: 0, storageLimit: 0)

  public init(fee: Tez, gasLimit: Int, storageLimit: Int) {
    self.fee = fee
    self.gasLimit = gasLimit
    self.storageLimit = storageLimit
  }
}
