// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

class OperationPayloadTest: XCTestCase {
  public func testDictionaryRepresentation() {
    let dictionaryRepresentation = OperationPayload.testOperationPayload.dictionaryRepresentation

    XCTAssertEqual(dictionaryRepresentation["branch"] as? String, String.testBranch)
  }
}
