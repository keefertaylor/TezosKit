// Copyright Keefer Taylor, 2018

import Foundation

/// An object encapsulating the payment for an operation on the blockchain.
public struct OperationFees {
  public let fee: Tez
  public let burnFee: Tez
  public let gasLimit: Int
  public let storageLimit: Int

  /// A zero-ed fees object.
  internal static let zeroFees = OperationFees(fee: .zeroBalance, gasLimit: 0, storageLimit: 0)

	public init(fee: Tez, burnFee: Tez = .zeroBalance, gasLimit: Int, storageLimit: Int) {
    self.fee = fee
	self.burnFee = burnFee
    self.gasLimit = gasLimit
    self.storageLimit = storageLimit
  }
}
