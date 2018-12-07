// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class DelegationOperationTest: XCTestCase {
  public func testDictionaryRepresentation() {
    let source = "tz1abc"
    let delegate = "tz1def"

    let operation = DelegationOperation(source: source, to: delegate)
    let dictionary = operation.dictionaryRepresentation

    XCTAssertNotNil(dictionary["source"])
    XCTAssertEqual(dictionary["source"] as! String, source)

    XCTAssertNotNil(dictionary["delegate"])
    XCTAssertEqual(dictionary["delegate"] as! String, delegate)
  }
}
