// Copyright Keefer Taylor, 2018

@testable import TezosKit
import XCTest

class KeysTests: XCTestCase {
  public func testEquality() {
    let keys1 = Keys(publicKey: "a", secretKey: "a")
    let keys2 = Keys(publicKey: "a", secretKey: "a")
    XCTAssertEqual(keys1, keys2)

    let keys3 = Keys(publicKey: "a", secretKey: "b")
    let keys4 = Keys(publicKey: "b", secretKey: "a")
    XCTAssertNotEqual(keys1, keys3)
    XCTAssertNotEqual(keys1, keys4)
  }
}
