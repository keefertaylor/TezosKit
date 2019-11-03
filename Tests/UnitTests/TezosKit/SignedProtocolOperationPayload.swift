// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

class SignedProtocolOperationPayloadTest: XCTestCase {
  public func testDictionaryRepresentation() {
    let dictionaryRepresentation =
      SignedProtocolOperationPayload.testSignedProtocolOperationPayload.dictionaryRepresentation

    XCTAssertEqual(dictionaryRepresentation.count, 1)
    XCTAssertEqual(dictionaryRepresentation[0]["protocol"] as? String, String.testProtocol)
  }
}
