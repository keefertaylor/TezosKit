// Copyright Keefer Taylor, 2019

import TezosKit
import XCTest

class OperationWithCounterTest: XCTestCase {
  public func testDictionaryRepresentation() {
    let dictionaryRepresentation = OperationWithCounter.testOperationWithCounter.dictionaryRepresentation
    XCTAssertEqual(dictionaryRepresentation["counter"] as? String, String(Int.testAddressCounter))
  }
}
