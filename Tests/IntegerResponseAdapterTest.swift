// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class IntegerResponseAdapterTest: XCTestCase {
  let integer = 123
  let integerString = "123"

  public func testParseInteger() {
    guard let balanceData = integerString.data(using: .utf8),
      let parsedInteger = IntegerResponseAdapter.parse(input: balanceData) else {
      XCTFail()
      return
    }

    XCTAssertNotNil(parsedInteger)
    XCTAssertEqual(parsedInteger, integer)
  }

  // Balances are returned as quoted from the API. Make sure that quotes can be stripped when
  // parsing.
  public func testParseIntegerWithQuotes() {
    guard let balanceData = ("\"" + integerString + "\"").data(using: .utf8),
      let parsedInteger = IntegerResponseAdapter.parse(input: balanceData) else {
      XCTFail()
      return
    }

    XCTAssertNotNil(parsedInteger)
    XCTAssertEqual(parsedInteger, integer)
  }

  // Ensure white space does not mess up parsing.
  public func testParseIntegerWithWhitespace() {
    guard let balanceData = ("    " + integerString + "\n\n\n").data(using: .utf8),
      let parsedInteger = IntegerResponseAdapter.parse(input: balanceData) else {
      XCTFail()
      return
    }

    XCTAssertNotNil(parsedInteger)
    XCTAssertEqual(parsedInteger, integer)
  }

  // Ensure invalid strings cannot be parsed.
  public func testParseIntegerWithInvalidInput() {
    let invalidIntegerString = "xyz"
    guard let invalidIntegerData = invalidIntegerString.data(using: .utf8) else {
      XCTFail()
      return
    }
    let parsedInteger = IntegerResponseAdapter.parse(input: invalidIntegerData)

    XCTAssertNil(parsedInteger)
  }
}
