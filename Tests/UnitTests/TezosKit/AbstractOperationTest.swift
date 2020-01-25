// Copyright Keefer Taylor, 2018

@testable import TezosKit
import XCTest

class AbstractOperationTest: XCTestCase {
  public func testRequiresReveal() {
    let abstractOperationRequiringReveal = AbstractOperation(
      source: "tz1abc",
      kind: .delegation,
      operationFees: OperationFees.testFees
    )
    XCTAssertTrue(abstractOperationRequiringReveal.requiresReveal)

    let abstractOperationNotRequiringReveal = AbstractOperation(
      source: "tz1abc",
      kind: .reveal,
      operationFees: OperationFees.testFees
    )
    XCTAssertFalse(abstractOperationNotRequiringReveal.requiresReveal)
  }

  public func testDictionaryRepresentation() {
    let source = "tz1abc"
    let kind: OperationKind = .delegation
    let fee = Tez(1)
    let gasLimit = 200
    let storageLimit = 300
    let operationFees = OperationFees(fee: fee, gasLimit: gasLimit, storageLimit: storageLimit)

    let abstractOperation = AbstractOperation(source: source, kind: kind, operationFees: operationFees)
    let dictionary = abstractOperation.dictionaryRepresentation

    XCTAssertNotNil(dictionary["source"])
    XCTAssertEqual(dictionary["source"] as? String, source)

    XCTAssertNotNil(dictionary["kind"])
    XCTAssertEqual(dictionary["kind"] as? String, kind.rawValue)

    XCTAssertNotNil(dictionary["fee"])
    XCTAssertEqual(dictionary["fee"] as? String, fee.rpcRepresentation)

    XCTAssertNotNil(dictionary["gas_limit"])
    XCTAssertEqual(dictionary["gas_limit"] as? String, String(gasLimit))

    XCTAssertNotNil(dictionary["storage_limit"])
    XCTAssertEqual(dictionary["storage_limit"] as? String, String(storageLimit))
  }
}
