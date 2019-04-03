// Copyright Keefer Taylor, 2019

import TezosKit
import XCTest

final class ConseilNetworkTest: XCTestCase {
  func testNetworkRawValueURLEncoded() {
    for network in ConseilNetwork.allCases {
      guard let escapedNetwork = network.rawValue.addingPercentEncoding(
        withAllowedCharacters: CharacterSet.urlQueryAllowed
        ) else {
          XCTFail()
          return
      }
      XCTAssertEqual(network.rawValue, escapedNetwork)
    }
  }
}
