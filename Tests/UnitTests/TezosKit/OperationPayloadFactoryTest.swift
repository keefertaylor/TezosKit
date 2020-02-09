// Copyright Keefer Taylor, 2019.

@testable import TezosKit
import XCTest

final class OperationPayloadFactoryTest: XCTestCase {
//  let signatureProvider = FakeSignatureProvider(signature: .testSignature, publicKey: FakePublicKey.testPublicKey)
//  let operationMetadataWithRevealedKey = OperationMetadata(
//    chainID: .testChainID,
//    branch: .testBranch,
//    protocol: .testProtocol,
//    addressCounter: .testAddressCounter,
//    key: .testPublicKey
//  )
//  let operationMetadataWithUnrevealedKey = OperationMetadata(
//    chainID: .testChainID,
//    branch: .testBranch,
//    protocol: .testProtocol,
//    addressCounter: .testAddressCounter,
//    key: nil
//  )
//
//  /// Test a single operation with a revealed manager key.
//  func testOperationPayloadInitSingleOperation() {
//    let operations = [
//      OperationFactory.testFactory.delegateOperation(
//        source: .testAddress,
//        to: .testDestinationAddress,
//        operationFeePolicy: .default,
//        signatureProvider: FakeSignatureProvider.testSignatureProvider
//      )!
//    ]
//
//    let operationPayload = OperationPayloadFactory.operationPayload(
//      from: operations,
//      source: .testAddress,
//      signatureProvider: signatureProvider,
//      operationMetadata: operationMetadataWithRevealedKey
//    )!
//
//    XCTAssertEqual(operationPayload.operations.count, operations.count)
//    verifyOperationCountersInAscendingOrder(
//      operations: operationPayload.operations,
//      initialCounter: .testAddressCounter
//    )
//  }
//
//  /// Test multiple operations with a revealed manager key.
//  func testOperationPayloadInitMultipleOperations() {
//    let operations = [
//      OperationFactory.testFactory.delegateOperation(
//        source: .testAddress,
//        to: .testDestinationAddress,
//        operationFeePolicy: .default,
//        signatureProvider: FakeSignatureProvider.testSignatureProvider
//      )!,
//      OperationFactory.testFactory.registerDelegateOperation(
//        source: .testAddress,
//        operationFeePolicy: .default,
//        signatureProvider: FakeSignatureProvider.testSignatureProvider
//      )!
//    ]
//
//    let operationPayload = OperationPayloadFactory.operationPayload(
//      from: operations,
//      source: .testAddress,
//      signatureProvider: signatureProvider,
//      operationMetadata: operationMetadataWithRevealedKey
//    )!
//
//    XCTAssertEqual(operationPayload.operations.count, operations.count)
//    verifyOperationCountersInAscendingOrder(
//      operations: operationPayload.operations,
//      initialCounter: .testAddressCounter
//    )
//  }
//
//  /// Test an operation requiring a reveal without a revealed manager key.
//  func testOperationPayloadInitWithUnrevealedKeyRevealRequired() {
//    let operations = [
//      OperationFactory.testFactory.delegateOperation(
//        source: .testAddress,
//        to: .testDestinationAddress,
//        operationFeePolicy: .default,
//        signatureProvider: FakeSignatureProvider.testSignatureProvider
//      )!,
//      OperationFactory.testFactory.registerDelegateOperation(
//        source: .testAddress,
//        operationFeePolicy: .default,
//        signatureProvider: FakeSignatureProvider.testSignatureProvider
//      )!
//    ]
//
//    let operationPayload = OperationPayloadFactory.operationPayload(
//      from: operations,
//      source: .testAddress,
//      signatureProvider: signatureProvider,
//      operationMetadata: operationMetadataWithUnrevealedKey
//    )!
//
//    // Expected a reveal operation.
//    XCTAssertEqual(operationPayload.operations.count, operations.count + 1)
//    XCTAssertEqual(operationPayload.operations.first!.operation.kind, .reveal)
//    verifyOperationCountersInAscendingOrder(
//      operations: operationPayload.operations,
//      initialCounter: .testAddressCounter
//    )
//  }
//
//  /// Test an operation not requiring a reveal without a revealed manager key.
//  func testOperationPayloadInitWithUnrevealedKeyRevealNotRequired() {
//    let operations = [
//      OperationFactory.testFactory.revealOperation(
//        from: .testAddress,
//        publicKey: signatureProvider.publicKey,
//        operationFeePolicy: .default,
//        signatureProvider: FakeSignatureProvider.testSignatureProvider
//      )!
//    ]
//
//    let operationPayload = OperationPayloadFactory.operationPayload(
//      from: operations,
//      source: .testAddress,
//      signatureProvider: signatureProvider,
//      operationMetadata: operationMetadataWithUnrevealedKey
//    )!
//
//    XCTAssertEqual(operationPayload.operations.count, operations.count)
//    verifyOperationCountersInAscendingOrder(
//      operations: operationPayload.operations,
//      initialCounter: .testAddressCounter
//    )
//  }
//
//  func testDictionaryRepresentation() {
//    let dictionaryRepresentation = OperationPayload.testOperationPayload.dictionaryRepresentation
//    XCTAssertEqual(dictionaryRepresentation["branch"] as? String, String.testBranch)
//  }
//
//  // MARK: - Helpers
//
//  private func verifyOperationCountersInAscendingOrder(operations: [OperationWithCounter], initialCounter: Int) {
//    var expectedCounter = initialCounter + 1
//    for operation in operations {
//      XCTAssertEqual(operation.counter, expectedCounter)
//      expectedCounter += 1
//    }
//  }
}
