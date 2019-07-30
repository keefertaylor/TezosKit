// Copyright Keefer Taylor, 2019.

@testable import TezosKit
import XCTest

final class OperationPayloadTest: XCTestCase {
  let operationFactory = OperationFactory()
  let signatureProvider = FakeSignatureProvider(signature: .testSignature, publicKey: FakePublicKey.testPublicKey)
  let operationMetadataWithRevealedKey = OperationMetadata(
    branch: .testBranch,
    protocol: .testProtocol,
    addressCounter: .testAddressCounter,
    key: .testPublicKey
  )
  let operationMetadataWithUnrevealedKey = OperationMetadata(
    branch: .testBranch,
    protocol: .testProtocol,
    addressCounter: .testAddressCounter,
    key: nil
  )

  /// Test a single operation with a revealed manager key.
  func testOperationPayloadInitSingleOperation() {
    let operations = [
      operationFactory.delegateOperation(source: .testAddress, to: .testDestinationAddress, operationFees: nil)
    ]

    let operationPayload = OperationPayload(
      operations: operations,
      operationFactory: operationFactory,
      operationMetadata: operationMetadataWithRevealedKey,
      source: .testAddress,
      signatureProvider: signatureProvider
    )

    XCTAssertEqual(operationPayload.operations.count, operations.count)
    verifyOperationCountersInAscendingOrder(
      operations: operationPayload.operations,
      initialCounter: .testAddressCounter
    )
  }

  /// Test multiple operations with a revealed manager key.
  func testOperationPayloadInitMultipleOperations() {
    let operations = [
      operationFactory.delegateOperation(source: .testAddress, to: .testDestinationAddress, operationFees: nil),
      operationFactory.registerDelegateOperation(source: .testAddress, operationFees: nil)
    ]

    let operationPayload = OperationPayload(
      operations: operations,
      operationFactory: operationFactory,
      operationMetadata: operationMetadataWithRevealedKey,
      source: .testAddress,
      signatureProvider: signatureProvider
    )

    XCTAssertEqual(operationPayload.operations.count, operations.count)
    verifyOperationCountersInAscendingOrder(
      operations: operationPayload.operations,
      initialCounter: .testAddressCounter
    )
  }

  /// Test an operation requiring a reveal without a revealed manager key.
  func testOperationPayloadInitWithUnrevealedKeyRevealRequired() {
    let operations = [
      operationFactory.delegateOperation(source: .testAddress, to: .testDestinationAddress, operationFees: nil),
      operationFactory.registerDelegateOperation(source: .testAddress, operationFees: nil)
    ]

    let operationPayload = OperationPayload(
      operations: operations,
      operationFactory: operationFactory,
      operationMetadata: operationMetadataWithUnrevealedKey,
      source: .testAddress,
      signatureProvider: signatureProvider
    )

    // Expected a reveal operation.
    XCTAssertEqual(operationPayload.operations.count, operations.count + 1)
    XCTAssertEqual(operationPayload.operations.first!.operation.kind, .reveal)
    verifyOperationCountersInAscendingOrder(
      operations: operationPayload.operations,
      initialCounter: .testAddressCounter
    )
  }

  /// Test an operation not requiring a reveal without a revealed manager key.
  func testOperationPayloadInitWithUnrevealedKeyRevealNotRequired() {
    let operations = [
      operationFactory.revealOperation(from: .testAddress, publicKey: signatureProvider.publicKey, operationFees: nil)
    ]

    let operationPayload = OperationPayload(
      operations: operations,
      operationFactory: operationFactory,
      operationMetadata: operationMetadataWithUnrevealedKey,
      source: .testAddress,
      signatureProvider: signatureProvider
    )

    XCTAssertEqual(operationPayload.operations.count, operations.count)
    verifyOperationCountersInAscendingOrder(
      operations: operationPayload.operations,
      initialCounter: .testAddressCounter
    )
  }

  func testDictionaryRepresentation() {
    let dictionaryRepresentation = OperationPayload.testOperationPayload.dictionaryRepresentation
    XCTAssertEqual(dictionaryRepresentation["branch"] as? String, String.testBranch)
  }

  // MARK: - Helpers

  private func verifyOperationCountersInAscendingOrder(operations: [OperationWithCounter], initialCounter: Int) {
    var expectedCounter = initialCounter + 1
    for operation in operations {
      XCTAssertEqual(operation.counter, expectedCounter)
      expectedCounter += 1
    }
  }
}
