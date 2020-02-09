// Copyright Keefer Taylor, 2019.

@testable import TezosKit
import XCTest

class OperationFactoryTest: XCTestCase {
  private let operationFactory = OperationFactory(
    feeEstimator: .testFeeEstimator
  )

  // MARK: - Default Fees
//
//  func testRevealOperationWithDefaultFees() {
//    let revealOperation = operationFactory.revealOperation(
//      from: "tz1abc",
//      publicKey: FakePublicKey(base58CheckRepresentation: "xyz", signingCurve: .ed25519),
//      operationFeePolicy: .default,
//      signatureProvider: FakeSignatureProvider.testSignatureProvider
//    )!
//
//    let defaultFees = DefaultFeeProvider.fees(for: .reveal)
//    XCTAssertEqual(revealOperation.operationFees.fee, defaultFees.fee)
//    XCTAssertEqual(revealOperation.operationFees.gasLimit, defaultFees.gasLimit)
//    XCTAssertEqual(revealOperation.operationFees.storageLimit, defaultFees.storageLimit)
//  }
//
//  func testTransactionOperationWithDefaultFees() {
//    let transactionOperation = operationFactory.transactionOperation(
//      amount: Tez(1.0),
//      source: "tz1abc",
//      destination: "tz2xyz",
//      operationFeePolicy: .default,
//      signatureProvider: FakeSignatureProvider.testSignatureProvider
//    )!
//
//    let defaultFees = DefaultFeeProvider.fees(for: .transaction)
//    XCTAssertEqual(transactionOperation.operationFees.fee, defaultFees.fee)
//    XCTAssertEqual(transactionOperation.operationFees.gasLimit, defaultFees.gasLimit)
//    XCTAssertEqual(transactionOperation.operationFees.storageLimit, defaultFees.storageLimit)
//  }
//
//  func testDelegationOperationWithDefaultFees() {
//    let delegationOperation = operationFactory.delegateOperation(
//      source: "tz1abc",
//      to: "tz2xyz",
//      operationFeePolicy: .default,
//      signatureProvider: FakeSignatureProvider.testSignatureProvider
//    )!
//
//    let defaultFees = DefaultFeeProvider.fees(for: .delegation)
//    XCTAssertEqual(delegationOperation.operationFees.fee, defaultFees.fee)
//    XCTAssertEqual(delegationOperation.operationFees.gasLimit, defaultFees.gasLimit)
//    XCTAssertEqual(delegationOperation.operationFees.storageLimit, defaultFees.storageLimit)
//  }
//
//  func testRegisterDelegateOperationWithDefaultFees() {
//    let registerDelegateOperation = operationFactory.registerDelegateOperation(
//      source: "tz1abc",
//      operationFeePolicy: .default,
//      signatureProvider: FakeSignatureProvider.testSignatureProvider
//    )!
//
//    let defaultFees = DefaultFeeProvider.fees(for: .delegation)
//    XCTAssertEqual(registerDelegateOperation.operationFees.fee, defaultFees.fee)
//    XCTAssertEqual(registerDelegateOperation.operationFees.gasLimit, defaultFees.gasLimit)
//    XCTAssertEqual(registerDelegateOperation.operationFees.storageLimit, defaultFees.storageLimit)
//  }
//
//  func testUndelegateOperationWithDefaultFees() {
//    let clearDelegateOperation = operationFactory.undelegateOperation(
//      source: "tz1abc",
//      operationFeePolicy: .default,
//      signatureProvider: FakeSignatureProvider.testSignatureProvider
//    )!
//
//    let defaultFees = DefaultFeeProvider.fees(for: .delegation)
//    XCTAssertEqual(clearDelegateOperation.operationFees.fee, defaultFees.fee)
//    XCTAssertEqual(clearDelegateOperation.operationFees.gasLimit, defaultFees.gasLimit)
//    XCTAssertEqual(clearDelegateOperation.operationFees.storageLimit, defaultFees.storageLimit)
//  }
//
//  // MARK: - Custom Fees
//
//  func testRevealOperationWithCustomFees() {
//    let revealOperation = operationFactory.revealOperation(
//      from: "tz1abc",
//      publicKey: FakePublicKey(base58CheckRepresentation: "xyz", signingCurve: .ed25519),
//      operationFeePolicy: .custom(.testFees),
//      signatureProvider: FakeSignatureProvider.testSignatureProvider
//    )!
//
//    XCTAssertEqual(revealOperation.operationFees.fee, OperationFees.testFees.fee)
//    XCTAssertEqual(revealOperation.operationFees.gasLimit, OperationFees.testFees.gasLimit)
//    XCTAssertEqual(revealOperation.operationFees.storageLimit, OperationFees.testFees.storageLimit)
//  }
//
//  func testTransactionOperationWithCustomFees() {
//    let transactionOperation = operationFactory.transactionOperation(
//      amount: Tez(1.0),
//      source: "tz1abc",
//      destination: "tz2xyz",
//      operationFeePolicy: .custom(.testFees),
//      signatureProvider: FakeSignatureProvider.testSignatureProvider
//    )!
//
//    XCTAssertEqual(transactionOperation.operationFees.fee, OperationFees.testFees.fee)
//    XCTAssertEqual(transactionOperation.operationFees.gasLimit, OperationFees.testFees.gasLimit)
//    XCTAssertEqual(transactionOperation.operationFees.storageLimit, OperationFees.testFees.storageLimit)
//  }
//
//  func testDelegationOperationWithCustomFees() {
//    let delegationOperation = operationFactory.delegateOperation(
//      source: "tz1abc",
//      to: "tz2xyz",
//      operationFeePolicy: .custom(.testFees),
//      signatureProvider: FakeSignatureProvider.testSignatureProvider
//    )!
//
//    XCTAssertEqual(delegationOperation.operationFees.fee, OperationFees.testFees.fee)
//    XCTAssertEqual(delegationOperation.operationFees.gasLimit, OperationFees.testFees.gasLimit)
//    XCTAssertEqual(delegationOperation.operationFees.storageLimit, OperationFees.testFees.storageLimit)
//  }
//
//  func testRegisterDelegateOperationWithCustomFees() {
//    let registerDelegateOperation = operationFactory.registerDelegateOperation(
//      source: "tz1abc",
//      operationFeePolicy: .custom(.testFees),
//      signatureProvider: FakeSignatureProvider.testSignatureProvider
//    )!
//
//    XCTAssertEqual(registerDelegateOperation.operationFees.fee, OperationFees.testFees.fee)
//    XCTAssertEqual(registerDelegateOperation.operationFees.gasLimit, OperationFees.testFees.gasLimit)
//    XCTAssertEqual(registerDelegateOperation.operationFees.storageLimit, OperationFees.testFees.storageLimit)
//  }
//
//  func testUndelegateOperationWithCustomFees() {
//    let clearDelegateOperation = operationFactory.undelegateOperation(
//      source: "tz1abc",
//      operationFeePolicy: .custom(.testFees),
//      signatureProvider: FakeSignatureProvider.testSignatureProvider
//    )!
//
//    XCTAssertEqual(clearDelegateOperation.operationFees.fee, OperationFees.testFees.fee)
//    XCTAssertEqual(clearDelegateOperation.operationFees.gasLimit, OperationFees.testFees.gasLimit)
//    XCTAssertEqual(clearDelegateOperation.operationFees.storageLimit, OperationFees.testFees.storageLimit)
//  }
}
