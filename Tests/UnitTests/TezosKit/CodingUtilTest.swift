// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

class CryptoUtilTest: XCTestCase {
  public func testHexToBin() {
    XCTAssertEqual(CodingUtil.hexToBin("1234"), [18, 52])
  }

  public func testBinToHex() {
    XCTAssertEqual(CodingUtil.binToHex([18, 52]), "1234")
  }
}
