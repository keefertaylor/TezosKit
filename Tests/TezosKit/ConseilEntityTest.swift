// Copyright Keefer Taylor, 2019

import TezosKit
import XCTest

final class ConseilEntityTest: XCTestCase {
  func testEntityRawValueURLEncoded() {
    for entity in ConseilEntity.allCases {
      guard let escapedEntity =
        entity.rawValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
          XCTFail()
          return
      }
      XCTAssertEqual(entity.rawValue, escapedEntity)
    }
  }
}
