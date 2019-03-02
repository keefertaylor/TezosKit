// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

class SignedOperationPayloadTest: XCTestCase {
  public func testDictionaryRepresentation() {
    let dictionaryRepresentation = SignedOperationPayload.testSignedOperationPayload.dictionaryRepresentation
    XCTAssertEqual(dictionaryRepresentation["signature"] as? String, String.testSignature)
  }
}
