// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An object encapsulating the payment for an operation on the blockchain.
 */
public struct OperationFees {
  public let fee: TezosBalance
  public let gasLimit: TezosBalance
  public let storageLimit: TezosBalance
}
