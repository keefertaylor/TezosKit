// Copyright Keefer Taylor, 2018

import Foundation

/// An object encapsulating the payment for an operation on the blockchain.
public struct OperationFees {
  public let fee: Tez
  public let gasLimit: Int
  public let storageLimit: Int
}
