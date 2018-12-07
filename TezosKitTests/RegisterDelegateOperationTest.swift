// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class RegisterDelegateOperationTest: XCTestCase {
  public func testDictionaryRepresentation() {
    let source = "tz1abc"

    let operation = RegisterDelegateOperation(delegate: source)
    let dictionary = operation.dictionaryRepresentation

    XCTAssertNotNil(dictionary["source"])
    XCTAssertEqual(dictionary["source"] as! String, source)

    XCTAssertNotNil(dictionary["delegate"])
    XCTAssertEqual(dictionary["delegate"] as! String, source)
  }
}
