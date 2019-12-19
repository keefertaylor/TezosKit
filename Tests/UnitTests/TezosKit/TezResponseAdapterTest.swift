// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class TezResponseAdapterTest: XCTestCase {
  public func testParseBalance() {
    guard let balance = Tez("3500000"),
      let balanceData = balance.rpcRepresentation.data(using: .utf8),
      let parsedBalance = TezResponseAdapter.parse(input: balanceData) else {
      XCTFail()
      return
    }

    XCTAssertNotNil(parsedBalance)
    XCTAssertEqual(parsedBalance, balance)
  }

  // Balances are returned as quoted from the API. Make sure that quotes can be stripped when
  // parsing.
  public func testParseBalanceWithQuotes() {
    guard let balance = Tez("3500000"),
      let balanceData = ("\"" + balance.rpcRepresentation + "\"").data(using: .utf8),
      let parsedBalance = TezResponseAdapter.parse(input: balanceData) else {
      XCTFail()
      return
    }

    XCTAssertNotNil(parsedBalance)
    XCTAssertEqual(parsedBalance, balance)
  }

  // Ensure white space does not mess up parsing.
  public func testParseBalanceWithWhitespace() {
    guard let balance = Tez("3500000"),
      let balanceData = ("    " + balance.rpcRepresentation + "\n\n\n").data(using: .utf8),
      let parsedBalance = TezResponseAdapter.parse(input: balanceData) else {
      XCTFail()
      return
    }

    XCTAssertNotNil(parsedBalance)
    XCTAssertEqual(parsedBalance, balance)
  }

  // Ensure invalid strings cannot be parsed.
  public func testParseBalanceWithInvalidInput() {
    let invalidBalanceString = "xyz"
    guard let invalidBalanceData = invalidBalanceString.data(using: .utf8) else {
      XCTFail()
      return
    }
    let parsedBalance = TezResponseAdapter.parse(input: invalidBalanceData)

    XCTAssertNil(parsedBalance)
  }
}
