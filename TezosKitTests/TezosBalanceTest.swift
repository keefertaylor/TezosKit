// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class TezosBalanceTest: XCTestCase {
  public func testHumanReadableRepresentationWithDecimalNumber() {
    guard let balanceFromStringNoLeadingZeros = TezosBalance(balance: "3500000"),
      let balanceFromStringLeadingZeros = TezosBalance(balance: "3050000") else {
      XCTFail()
      return
    }
    let balanceFromNumberNoLeadingZeros = TezosBalance(balance: 3.50)
    let balanceFromNumberLeadingZeros = TezosBalance(balance: 3.05)

    XCTAssertEqual(balanceFromNumberNoLeadingZeros.humanReadableRepresentation, "3.500000")
    XCTAssertEqual(balanceFromStringNoLeadingZeros.humanReadableRepresentation, "3.500000")

    XCTAssertEqual(balanceFromStringLeadingZeros.humanReadableRepresentation, "3.050000")
    XCTAssertEqual(balanceFromNumberLeadingZeros.humanReadableRepresentation, "3.050000")
  }

  public func testRPCRepresentationWithDecimalNumber() {
    guard let balanceFromStringNoLeadingZeros = TezosBalance(balance: "3500000"),
      let balanceFromStringLeadingZeros = TezosBalance(balance: "3050000") else {
      XCTFail()
      return
    }
    let balanceFromNumberNoLeadingZeros = TezosBalance(balance: 3.50)
    let balanceFromNumberLeadingZeros = TezosBalance(balance: 3.05)

    XCTAssertEqual(balanceFromNumberNoLeadingZeros.rpcRepresentation, "3500000")
    XCTAssertEqual(balanceFromStringNoLeadingZeros.rpcRepresentation, "3500000")

    XCTAssertEqual(balanceFromStringLeadingZeros.rpcRepresentation, "3050000")
    XCTAssertEqual(balanceFromNumberLeadingZeros.rpcRepresentation, "3050000")
  }

  public func testHumanReadableRepresentationWithWholeNumber() {
    guard let balanceFromString = TezosBalance(balance: "3000000") else {
      XCTFail()
      return
    }
    let balanceFromNumber = TezosBalance(balance: 3.00)

    XCTAssertEqual(balanceFromNumber.humanReadableRepresentation, "3.000000")
    XCTAssertEqual(balanceFromString.humanReadableRepresentation, "3.000000")
  }

  public func testRPCRepresentationWithWholeNumber() {
    guard let balanceFromString = TezosBalance(balance: "3000000") else {
      XCTFail()
      return
    }
    let balanceFromNumber = TezosBalance(balance: 3.00)

    XCTAssertEqual(balanceFromNumber.rpcRepresentation, "3000000")
    XCTAssertEqual(balanceFromString.rpcRepresentation, "3000000")
  }

  public func testBalanceFromInvalidString() {
    let balance = TezosBalance(balance: "3.50")
    XCTAssertNil(balance)
  }

  public func testBalanceFromStringSmallNumber() {
    guard let balance = TezosBalance(balance: "35") else {
      XCTFail()
      return
    }
    XCTAssertEqual(balance.humanReadableRepresentation, "0.000035")
  }

  public func testEquality() {
    guard let threeFiftyAsString = TezosBalance(balance: "3500000") else {
      XCTFail()
      return
    }

    let threeFiftyAsDecimal = TezosBalance(balance: 3.5)
    let fourAsDecimal = TezosBalance(balance: 4.0)

    XCTAssertEqual(threeFiftyAsString, threeFiftyAsDecimal)
    XCTAssertNotEqual(threeFiftyAsDecimal, fourAsDecimal)
  }
}
