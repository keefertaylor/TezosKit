// Copyright Keefer Taylor, 2019

import Foundation

/// A factory which can produce operation payloads
public class OperationPayloadFactory {
  private let operationFactory: OperationFactory

  public init(operationFactory: OperationFactory) {
    self.operationFactory = operationFactory
  }

  public func operationPayload(
    from operations: [Operation],
    source: Address,
    signatureProvider: SignatureProvider,
    operationMetadata: OperationMetadata
  ) -> OperationPayload {
    // Determine if the address performing the operations has been revealed. If it has not been, check if any of the
    // operations to perform requires the address to be revealed. If so, prepend a reveal operation to the operations to
    // perform.
    var mutableOperations = operations
    if operationMetadata.key == nil && operations.first(where: { $0.requiresReveal }) != nil {
      let revealOperation = operationFactory.revealOperation(
        from: source,
        publicKey: signatureProvider.publicKey,
        operationFeePolicy: .default,
        signatureProvider: signatureProvider
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

    return OperationPayload(operations: operationsWithCounter, operationMetadata: operationMetadata)
  }
}
