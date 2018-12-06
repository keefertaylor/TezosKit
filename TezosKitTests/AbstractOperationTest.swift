// Copyright Keefer Taylor, 2018

import TezosKit
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

    let abstractOperation = AbstractOperation(source: source, kind: kind)
    let dictionary = abstractOperation.dictionaryRepresentation

    XCTAssertNotNil(dictionary["source"])
    XCTAssertEqual(dictionary["source"], source)

    XCTAssertNotNil(dictionary["kind"])
    XCTAssertEqual(dictionary["kind"], kind.rawValue)
  }
}
