// Copyright Keefer Taylor, 2018

import Foundation

/**
 * Protocol representing all operations. Operations are first class representations of JSON objects
 * which can be forge / pre-applied / injected on the Tezos Blockchain.
 */
public protocol Operation {
  /** Whether the given operation requires the account to be revealed. */
  var requiresReveal: Bool { get }

  /** Retrieve a dictionary representing the operation. */
  var dictionaryRepresentation: [String: String] { get }
}
