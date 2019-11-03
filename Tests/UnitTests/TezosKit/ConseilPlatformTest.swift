// Copyright Keefer Taylor, 2019

import TezosKit
import XCTest

final class ConseilPlatformTest: XCTestCase {
  func testPlatformRawValueURLEncoded() {
    for platform in ConseilPlatform.allCases {
      guard let escapedPlatform = platform.rawValue.addingPercentEncoding(
        withAllowedCharacters: CharacterSet.urlQueryAllowed
        ) else {
          XCTFail()
          return
      }
      XCTAssertEqual(platform.rawValue, escapedPlatform)
    }
  }
}
