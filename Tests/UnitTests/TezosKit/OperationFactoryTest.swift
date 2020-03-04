// Copyright Keefer Taylor, 2019.

@testable import TezosKit
import XCTest

class OperationFactoryTest: XCTestCase {
  private let operationFactory = OperationFactory(
    feeEstimator: .testFeeEstimator
  )

  // MARK: - Default Fees

  func testRevealOperationWithDefaultFees() {
    guard case let .success(operation) = operationFactory.revealOperation(
      from: "tz1abc",
      publicKey: FakePublicKey.testPublicKey,
      operationFeePolicy: .default,
      signatureProvider: FakeSignatureProvider.testSignatureProvider
    ) else {
      XCTFail()
      return
    }

    let defaultFees = DefaultFeeProvider.fees(for: .reveal)
    XCTAssertEqual(operation.operationFees.fee, defaultFees.fee)
    XCTAssertEqual(operation.operationFees.gasLimit, defaultFees.gasLimit)
    XCTAssertEqual(operation.operationFees.storageLimit, defaultFees.storageLimit)
  }

  func testTransactionOperationWithDefaultFees() {
    guard case let .success(operation) = operationFactory.transactionOperation(
      amount: Tez(1.0),
      source: "tz1abc",
      destination: "tz2xyz",
      operationFeePolicy: .default,
      signatureProvider: FakeSignatureProvider.testSignatureProvider
    ) else {
      XCTFail()
      return
    }

    let defaultFees = DefaultFeeProvider.fees(for: .transaction)
    XCTAssertEqual(operation.operationFees.fee, defaultFees.fee)
    XCTAssertEqual(operation.operationFees.gasLimit, defaultFees.gasLimit)
    XCTAssertEqual(operation.operationFees.storageLimit, defaultFees.storageLimit)
  }

  func testDelegationOperationWithDefaultFees() {
    guard case let .success(operation) = operationFactory.delegateOperation(
      source: "tz1abc",
      to: "tz2xyz",
      operationFeePolicy: .default,
      signatureProvider: FakeSignatureProvider.testSignatureProvider
    ) else {
      XCTFail()
      return
    }

    let defaultFees = DefaultFeeProvider.fees(for: .delegation)
    XCTAssertEqual(operation.operationFees.fee, defaultFees.fee)
    XCTAssertEqual(operation.operationFees.gasLimit, defaultFees.gasLimit)
    XCTAssertEqual(operation.operationFees.storageLimit, defaultFees.storageLimit)
  }

  func testRegisterDelegateOperationWithDefaultFees() {
    guard case let .success(operation) = operationFactory.registerDelegateOperation(
      source: "tz1abc",
      operationFeePolicy: .default,
      signatureProvider: FakeSignatureProvider.testSignatureProvider
    ) else {
      XCTFail()
      return
    }

    let defaultFees = DefaultFeeProvider.fees(for: .delegation)
    XCTAssertEqual(operation.operationFees.fee, defaultFees.fee)
    XCTAssertEqual(operation.operationFees.gasLimit, defaultFees.gasLimit)
    XCTAssertEqual(operation.operationFees.storageLimit, defaultFees.storageLimit)
  }

  func testUndelegateOperationWithDefaultFees() {
    guard case let .success(operation) = operationFactory.undelegateOperation(
      source: "tz1abc",
      operationFeePolicy: .default,
      signatureProvider: FakeSignatureProvider.testSignatureProvider
    ) else {
      XCTFail()
      return
    }

    let defaultFees = DefaultFeeProvider.fees(for: .delegation)
    XCTAssertEqual(operation.operationFees.fee, defaultFees.fee)
    XCTAssertEqual(operation.operationFees.gasLimit, defaultFees.gasLimit)
    XCTAssertEqual(operation.operationFees.storageLimit, defaultFees.storageLimit)
  }

  // MARK: - Custom Fees

  func testRevealOperationWithCustomFees() {
    guard case let .success(operation) = operationFactory.revealOperation(
      from: "tz1abc",
      publicKey: FakePublicKey.testPublicKey,
      operationFeePolicy: .custom(.testFees),
      signatureProvider: FakeSignatureProvider.testSignatureProvider
    ) else {
      XCTFail()
      return
    }

    XCTAssertEqual(operation.operationFees.fee, OperationFees.testFees.fee)
    XCTAssertEqual(operation.operationFees.gasLimit, OperationFees.testFees.gasLimit)
    XCTAssertEqual(operation.operationFees.storageLimit, OperationFees.testFees.storageLimit)
  }

  func testTransactionOperationWithCustomFees() {
    guard case let .success(operation) = operationFactory.transactionOperation(
      amount: Tez(1.0),
      source: "tz1abc",
      destination: "tz2xyz",
      operationFeePolicy: .custom(.testFees),
      signatureProvider: FakeSignatureProvider.testSignatureProvider
    ) else {
      XCTFail()
      return
    }

    XCTAssertEqual(operation.operationFees.fee, OperationFees.testFees.fee)
    XCTAssertEqual(operation.operationFees.gasLimit, OperationFees.testFees.gasLimit)
    XCTAssertEqual(operation.operationFees.storageLimit, OperationFees.testFees.storageLimit)
  }

  func testDelegationOperationWithCustomFees() {
    guard case let .success(operation) = operationFactory.delegateOperation(
      source: "tz1abc",
      to: "tz2xyz",
      operationFeePolicy: .custom(.testFees),
      signatureProvider: FakeSignatureProvider.testSignatureProvider
    ) else {
      XCTFail()
      return
    }

    XCTAssertEqual(operation.operationFees.fee, OperationFees.testFees.fee)
    XCTAssertEqual(operation.operationFees.gasLimit, OperationFees.testFees.gasLimit)
    XCTAssertEqual(operation.operationFees.storageLimit, OperationFees.testFees.storageLimit)
  }

  func testRegisterDelegateOperationWithCustomFees() {
    guard case let .success(operation) = operationFactory.registerDelegateOperation(
      source: "tz1abc",
      operationFeePolicy: .custom(.testFees),
      signatureProvider: FakeSignatureProvider.testSignatureProvider
    ) else {
      XCTFail()
      return
    }

    XCTAssertEqual(operation.operationFees.fee, OperationFees.testFees.fee)
    XCTAssertEqual(operation.operationFees.gasLimit, OperationFees.testFees.gasLimit)
    XCTAssertEqual(operation.operationFees.storageLimit, OperationFees.testFees.storageLimit)
  }

  func testUndelegateOperationWithCustomFees() {
    guard case let .success(operation) = operationFactory.undelegateOperation(
      source: "tz1abc",
      operationFeePolicy: .custom(.testFees),
      signatureProvider: FakeSignatureProvider.testSignatureProvider
    ) else {
      XCTFail()
      return
    }

    XCTAssertEqual(operation.operationFees.fee, OperationFees.testFees.fee)
    XCTAssertEqual(operation.operationFees.gasLimit, OperationFees.testFees.gasLimit)
    XCTAssertEqual(operation.operationFees.storageLimit, OperationFees.testFees.storageLimit)
  }
}
