// Copyright Keefer Taylor, 2018

import Foundation

/**
 * A lightweight property bag containing data about the current chain state in order to
 * forge / preapply / inject operations on the Tezos blockchain.
 */
public struct OperationMetadata {
  /** The chain which is being operated on. */
  public let chainID: String

  /** The hash of the head of the chain being operated on. */
  public let headHash: String

  /** The hash of the protocol being operated on. */
  public let protocolHash: String

  /** The counter for the address being operated on. */
  public let addressCounter: Int

  /** The key for the address, or nil if the key is not yet revealed. */
  public let key: String?
}
