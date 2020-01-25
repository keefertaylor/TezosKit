// Copyright Keefer Taylor, 2018

import Foundation

/// Protocol representing all operations. Operations are first class representations of JSON object which can be forged
/// pre-applied / injected on the Tezos Blockchain.
public protocol Operation: NSMutableCopying {
  /// The kind of the operation.
  var kind: OperationKind { get }

  /// Whether the given operation requires the account to be revealed.
  var requiresReveal: Bool { get }

  /// Fees associated with the operation.
  var operationFees: OperationFees { get set }

  /// Retrieve a dictionary representing the operation.
  var dictionaryRepresentation: [String: Any] { get }
}
