// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class DelegationOperationTest: XCTestCase {
  public func testDictionaryRepresentation_delegate() {
    let source = "tz1abc"
    let delegate = "tz1def"

    guard case let .success(operation) = OperationFactory.testFactory.delegateOperation(
      source: source,
      to: delegate,
      operationFeePolicy: .default,
      signatureProvider: FakeSignatureProvider.testSignatureProvider
    ) else {
      XCTFail()
      return
    }
    let dictionary = operation.dictionaryRepresentation

    XCTAssertNotNil(dictionary["source"])
    XCTAssertEqual(dictionary["source"] as? String, source)

    XCTAssertNotNil(dictionary["delegate"])
    XCTAssertEqual(dictionary["delegate"] as? String, delegate)
  }

  public func testDictionaryRepresentation_undelegate() {
    let source = "tz1abc"

    guard case let .success(operation) = OperationFactory.testFactory.undelegateOperation(
      source: source,
      operationFeePolicy: .default,
      signatureProvider: FakeSignatureProvider.testSignatureProvider
    ) else {
      XCTFail()
      return
    }
    let dictionary = operation.dictionaryRepresentation

    XCTAssertNotNil(dictionary["source"])
    XCTAssertEqual(dictionary["source"] as? String, source)

    XCTAssertNil(dictionary["delegate"])
  }

  public func testDictionaryRepresentation_registerDelegate() {
    let source = "tz1abc"

    guard case let .success(operation) = OperationFactory.testFactory.registerDelegateOperation(
      source: source,
      operationFeePolicy: .default,
      signatureProvider: FakeSignatureProvider.testSignatureProvider
    ) else {
      XCTFail()
      return
    }
    let dictionary = operation.dictionaryRepresentation

    XCTAssertNotNil(dictionary["source"])
    XCTAssertEqual(dictionary["source"] as? String, source)

    XCTAssertNotNil(dictionary["delegate"])
    XCTAssertEqual(dictionary["delegate"] as? String, source)
  }
}
