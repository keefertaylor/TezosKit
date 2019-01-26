// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class JSONDictionaryResponseAdapterTest: XCTestCase {
  public func testParseDictionary() {
    let validJSONString = "{\"a\": \"b\", \"c\": { \"d\": \"e\" }}"
    guard let validJSONData = validJSONString.data(using: .utf8),
      let parsedDictionary = JSONDictionaryResponseAdapter.parse(input: validJSONData) else {
      XCTFail()
      return
    }

    XCTAssertNotNil(parsedDictionary["a"])
    guard let a = parsedDictionary["a"] as? String else {
      XCTFail()
      return
    }
    XCTAssertEqual(a, "b")

    XCTAssertNotNil(parsedDictionary["c"])
    guard let c = parsedDictionary["c"] as? [String: String],
      let d = c["d"] else {
      XCTFail()
      return
    }
    XCTAssertEqual(d, "e")
  }

  public func testParseDictionaryWithArray() {
    let validJSONString = "[{\"a\": \"b\", \"c\": { \"d\": \"e\" }}]"
    guard let validJSONData = validJSONString.data(using: .utf8) else {
      XCTFail()
      return
    }

    let parsedDictionary = JSONDictionaryResponseAdapter.parse(input: validJSONData)
    XCTAssertNil(parsedDictionary)
  }

  public func testParseDictionaryWithInvalidJSON() {
    let validJSONString = "abc:[]123"
    guard let validJSONData = validJSONString.data(using: .utf8) else {
      XCTFail()
      return
    }

    let parsedDictionary = JSONDictionaryResponseAdapter.parse(input: validJSONData)
    XCTAssertNil(parsedDictionary)
  }
}
