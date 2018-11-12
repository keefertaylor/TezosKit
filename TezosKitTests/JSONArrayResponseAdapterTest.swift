// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class JSONArrayResponseAdapterTest: XCTestCase {
  public func testParseArray() {
    let validJSONString = "[{\"a\": \"b\"}, {\"c\": \"d\"}, {\"e\": \"f\"}]"
    guard let validJSONData = validJSONString.data(using: .utf8),
      let parsedArray = JSONArrayResponseAdapter.parse(input: validJSONData) else {
      XCTFail()
      return
    }

    XCTAssertEqual(parsedArray.count, 3)
    XCTAssertNotNil(parsedArray[0])
    XCTAssertNotNil(parsedArray[1])
    XCTAssertNotNil(parsedArray[2])
  }

  public func testParseArrayWithDictionary() {
    let validJSONString = "{\"a\": \"b\", \"c\": { \"d\": \"e\" }}"
    guard let validJSONData = validJSONString.data(using: .utf8) else {
      XCTFail()
      return
    }

    let parsedArray = JSONArrayResponseAdapter.parse(input: validJSONData)
    XCTAssertNil(parsedArray)
  }

  public func testParseDictionaryWithInvalidJSON() {
    let validJSONString = "abc:[]123"
    guard let validJSONData = validJSONString.data(using: .utf8) else {
      XCTFail()
      return
    }

    let parsedArray = JSONArrayResponseAdapter.parse(input: validJSONData)
    XCTAssertNil(parsedArray)
  }
}
