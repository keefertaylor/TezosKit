// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class UndelegateOperationTest: XCTestCase {
  public func testDictionaryRepresentation() {
    let source = "tz1abc"

    let operation = UndelegateOperation(source: source)
    let dictionary = operation.dictionaryRepresentation

    XCTAssertNotNil(dictionary["source"])
    XCTAssertEqual(dictionary["source"] as! String, source)

    XCTAssertNil(dictionary["delegate"])
  }
}
