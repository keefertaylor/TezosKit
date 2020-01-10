// Copyright Keefer Taylor, 2020

import TezosKit
import XCTest

class PackDataResponseAdapterTest: XCTestCase {
  public func testParsePackedData() {
    let expected = "exprv6UsC1sN3Fk2XfgcJCL8NCerP5rCGy1PRESZAqr7L2JdzX55EN"
    let response = [
      "packed": "050a000000160000b2e19a9e74440d86c59f13dab8a18ff873e889ea",
      "gas": "799901"
    ]

    guard
      let jsonResponse = JSONUtils.jsonString(for: response),
      let data = jsonResponse.data(using: .utf8)
    else {
      XCTFail()
      return
    }

    let result = PackDataResponseAdapter.parse(input: data)

    XCTAssertEqual(result, expected)
  }
}
