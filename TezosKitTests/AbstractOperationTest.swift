// Copyright Keefer Taylor, 2018

@testable import TezosKit
import XCTest

class AbstractOperationTest: XCTestCase {
  public func testRequiresReveal() {
    let abstractOperationRequiringReveal = AbstractOperation(source: "tz1abc", kind: .delegation)
    XCTAssertTrue(abstractOperationRequiringReveal.requiresReveal)

    let abstractOperationNotRequiringReveal = AbstractOperation(source: "tz1abc", kind: .reveal)
    XCTAssertFalse(abstractOperationNotRequiringReveal.requiresReveal)
  }

  public func testDictionaryRepresentation() {
    let source = "tz1abc"
    let kind: OperationKind = .delegation
    let fee = TezosBalance(balance: 1)
    let gasLimit = TezosBalance(balance: 2)
    let storageLimit = TezosBalance(balance: 3)
    let operationFees = OperationFees(fee: fee, gasLimit: gasLimit, storageLimit: storageLimit)

    let abstractOperation = AbstractOperation(source: source,
                                              kind: kind,
                                              operationFees: operationFees)
    let dictionary = abstractOperation.dictionaryRepresentation

    XCTAssertNotNil(dictionary["source"])
    XCTAssertEqual(dictionary["source"] as! String, source)

    XCTAssertNotNil(dictionary["kind"])
    XCTAssertEqual(dictionary["kind"] as! String, kind.rawValue)

    XCTAssertNotNil(dictionary["fee"])
    XCTAssertEqual(dictionary["fee"] as! String, fee.rpcRepresentation)

    XCTAssertNotNil(dictionary["gas_limit"])
    XCTAssertEqual(dictionary["gas_limit"] as! String, gasLimit.rpcRepresentation)

    XCTAssertNotNil(dictionary["storage_limit"])
    XCTAssertEqual(dictionary["storage_limit"] as! String, storageLimit.rpcRepresentation)
  }
}
