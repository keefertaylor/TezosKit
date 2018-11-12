// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class StringResponseAdapterTest: XCTestCase {
  public func testParseString() {
    let string = "String"
    guard let data = string.data(using: .utf8) else {
      XCTFail()
      return
    }

    let result = StringResponseAdapter.parse(input: data)

    XCTAssertEqual(result, string)
  }

  // Expect quotes to be stripped.
  public func testQuotedString() {
    let string = "String"
    let quotedString = "\"" + string + "\""
    guard let data = quotedString.data(using: .utf8) else {
      XCTFail()
      return
    }

    let result = StringResponseAdapter.parse(input: data)

    XCTAssertEqual(result, string)
  }

  // Expect whitespace to be stripped.
  public func testWhitespaceString() {
    let string = "String"
    let quotedString = "   " + string + "\n   \n"
    guard let data = quotedString.data(using: .utf8) else {
      XCTFail()
      return
    }

    let result = StringResponseAdapter.parse(input: data)

    XCTAssertEqual(result, string)
  }

  // Test decode fails on non utf8 string
  public func testUnexpectedEncoding() {
    let string = "🙃"
    guard let data = string.data(using: .utf16) else {
      XCTFail()
      return
    }

    let result = StringResponseAdapter.parse(input: data)
    XCTAssertNil(result)
  }
}
