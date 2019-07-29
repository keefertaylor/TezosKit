// Copyright Keefer Taylor, 2019.

import Foundation

/// A payload that can be forged into operation bytes.
public struct OperationPayload {
  /// An array of dictionaries representing operations.
  internal let operations: [OperationWithCounter]

  /// The hash of the head of the chain to apply the operation on.
  internal let branch: String

  /// Retrieve a dictionary representation of the payload.
  public var dictionaryRepresentation: [String: Any] {
    var contents: [[String: Any]] = []
    for operation in operations {
      contents.append(operation.dictionaryRepresentation)
    }
    return [
      "contents": contents,
      "branch": branch
    ]
  }

  /// Creates a operation payload from a list of operations.
  ///
  /// This initializer will automatically add reveal operations and set address counters properly.
  ///
  /// - Parameters:
  ///   - operations: A list of operations to forge.
  ///   - operationFactory: An operation factory which can produce a reveal operation.
  ///   - operationMetadata: Metadata about the operations.
  ///   - source: The address executing the operations.
  ///   - signatureProvider: The object which will provide the public key.
  public init(
    operations: [Operation],
    operationFactory: OperationFactory,
    operationMetadata: OperationMetadata,
    source: Address,
    signatureProvider: SignatureProvider
  ) {
    // Determine if the address performing the operations has been revealed. If it has not been, check if any of the
    // operations to perform requires the address to be revealed. If so, prepend a reveal operation to the operations to
    // perform.
    var mutableOperations = operations
    if operationMetadata.key == nil && operations.first(where: { $0.requiresReveal }) != nil {
      let revealOperation = operationFactory.revealOperation(
        from: source,
        publicKey: signatureProvider.publicKey,
        operationFees: nil
      )
      mutableOperations.insert(revealOperation, at: 0)
    }

    // Process all operations to have increasing counters and place them in the contents array.
    var nextCounter = operationMetadata.addressCounter + 1
    var operationsWithCounter: [OperationWithCounter] = []
    for operation in mutableOperations {
      let operationWithCounter = OperationWithCounter(operation: operation, counter: nextCounter)
      operationsWithCounter.append(operationWithCounter)
      nextCounter += 1
    }

    self.operations = operationsWithCounter
    self.branch = operationMetadata.branch
  }
}
