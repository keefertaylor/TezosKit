import XCTest
import TezosKit

class JSONDictionaryResponseAdapterTest: XCTestCase {
  public func testParseDictionary() {
    let validJSONString = "{\"a\": \"b\", \"c\": { \"d\": \"e\" }}"
    guard let validJSONData = validJSONString.data(using: .utf8),
          let parsedDictionary = JSONDictionaryResponseAdapter.parse(input: validJSONData) else {
      XCTFail()
      return
    }

    XCTAssertNotNil(parsedDictionary["a"])
    XCTAssertEqual(parsedDictionary["a"] as! String, "b")

    XCTAssertNotNil(parsedDictionary["c"])

    XCTAssertNotNil((parsedDictionary["c"] as! [String: String])["d"])
    XCTAssertEqual((parsedDictionary["c"] as! [String: String])["d"] as! String, "e")
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
