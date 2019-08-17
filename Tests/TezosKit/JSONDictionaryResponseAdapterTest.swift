// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class JSONDictionaryResponseAdapterTest: XCTestCase {
  public func testParseDictionary() {
    let validJSONString = "{\"contents\":[{\"kind\":\"transaction\",\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"fee\":\"1\",\"counter\":\"31127\",\"gas_limit\":\"100000\",\"storage_limit\":\"10000\",\"amount\":\"1000000\",\"destination\":\"KT1D5jmrBD7bDa3jCpgzo32FMYmRDdK2ihka\",\"metadata\":{\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"change\":\"-1\"},{\"kind\":\"freezer\",\"category\":\"fees\",\"delegate\":\"tz1Ke2h7sDdakHJQh8WX4Z372du1KChsksyU\",\"cycle\":284,\"change\":\"1\"}],\"operation_result\":{\"status\":\"applied\",\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"change\":\"-1000000\"},{\"kind\":\"contract\",\"contract\":\"KT1D5jmrBD7bDa3jCpgzo32FMYmRDdK2ihka\",\"change\":\"1000000\"}],\"consumed_gas\":\"10200\"}}}]}"

//    let validJSONString = "{\"a\": \"b\", \"c\": { \"d\": \"e\" }}"
    guard let validJSONData = validJSONString.data(using: .utf8),
      let parsedDictionary = JSONDictionaryResponseAdapter.parse(input: validJSONData) else {
      XCTFail()
      return
    }
    print(parsedDictionary)
//
//    XCTAssertNotNil(parsedDictionary["a"])
//    guard let a = parsedDictionary["a"] as? String else {
//      XCTFail()
//      return
//    }
//    XCTAssertEqual(a, "b")
//
//    XCTAssertNotNil(parsedDictionary["c"])
//    guard let c = parsedDictionary["c"] as? [String: String],
//      let d = c["d"] else {
//      XCTFail()
//      return
//    }
//    XCTAssertEqual(d, "e")
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
