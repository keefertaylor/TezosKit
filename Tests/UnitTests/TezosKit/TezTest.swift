// Copyright Keefer Taylor, 2018

@testable import TezosKit
import XCTest

class TezTest: XCTestCase {
  public func testHumanReadableRepresentationWithDecimalNumber() {
    guard let balanceFromStringNoLeadingZeros = Tez("3500000"),
      let balanceFromStringLeadingZeros = Tez("3050000") else {
      XCTFail()
      return
    }
    let balanceFromNumberNoLeadingZeros = Tez(3.50)
    let balanceFromNumberLeadingZeros = Tez(3.05)

    XCTAssertEqual(balanceFromNumberNoLeadingZeros.humanReadableRepresentation, "3.500000")
    XCTAssertEqual(balanceFromStringNoLeadingZeros.humanReadableRepresentation, "3.500000")

    XCTAssertEqual(balanceFromStringLeadingZeros.humanReadableRepresentation, "3.050000")
    XCTAssertEqual(balanceFromNumberLeadingZeros.humanReadableRepresentation, "3.050000")
  }

  public func testRPCRepresentationWithDecimalNumber() {
    guard let balanceFromStringNoLeadingZeros = Tez("3500000"),
      let balanceFromStringLeadingZeros = Tez("3050000") else {
      XCTFail()
      return
    }
    let balanceFromNumberNoLeadingZeros = Tez(3.50)
    let balanceFromNumberLeadingZeros = Tez(3.05)

    XCTAssertEqual(balanceFromNumberNoLeadingZeros.rpcRepresentation, "3500000")
    XCTAssertEqual(balanceFromStringNoLeadingZeros.rpcRepresentation, "3500000")

    XCTAssertEqual(balanceFromStringLeadingZeros.rpcRepresentation, "3050000")
    XCTAssertEqual(balanceFromNumberLeadingZeros.rpcRepresentation, "3050000")
  }

  public func testHumanReadableRepresentationWithWholeNumber() {
    guard let balanceFromString = Tez("3000000") else {
      XCTFail()
      return
    }
    let balanceFromNumber = Tez(3.00)

    XCTAssertEqual(balanceFromNumber.humanReadableRepresentation, "3.000000")
    XCTAssertEqual(balanceFromString.humanReadableRepresentation, "3.000000")
  }

  public func testRPCRepresentationWithWholeNumber() {
    guard let balanceFromString = Tez("3000000") else {
      XCTFail()
      return
    }
    let balanceFromNumber = Tez(3.00)

    XCTAssertEqual(balanceFromNumber.rpcRepresentation, "3000000")
    XCTAssertEqual(balanceFromString.rpcRepresentation, "3000000")
  }

  public func testRPCRepresentationWithSmallNumber() {
    guard let balanceFromString = Tez("10") else {
      XCTFail()
      return
    }
    let balanceFromNumber = Tez(0.000_010)

    XCTAssertEqual(balanceFromNumber.rpcRepresentation, "10")
    XCTAssertEqual(balanceFromString.rpcRepresentation, "10")
  }

  public func testHumanReadableRepresentationWithSmallNumber() {
    guard let balanceFromString = Tez("10") else {
      XCTFail()
      return
    }
    let balanceFromNumber = Tez(0.000_010)

    XCTAssertEqual(balanceFromNumber.humanReadableRepresentation, "0.000010")
    XCTAssertEqual(balanceFromString.humanReadableRepresentation, "0.000010")
  }

  public func testBalanceFromInvalidString() {
    let balance = Tez("3.50")
    XCTAssertNil(balance)
  }

  public func testBalanceFromStringSmallNumber() {
    guard let balance = Tez("35") else {
      XCTFail()
      return
    }
    XCTAssertEqual(balance.humanReadableRepresentation, "0.000035")
  }

  public func testEquality() {
    guard let threeFiftyAsString = Tez("3500000") else {
      XCTFail()
      return
    }

    let threeFiftyAsDecimal = Tez(3.5)
    let fourAsDecimal = Tez(4.0)

    XCTAssertEqual(threeFiftyAsString, threeFiftyAsDecimal)
    XCTAssertNotEqual(threeFiftyAsDecimal, fourAsDecimal)
  }

  public func testVeryLargeAmout() {
    guard let oneQuadrillionAsString = Tez("1000000000000000000000") else {
      XCTFail()
      return
    }

    let oneQuadrillionAsDecimal = Tez(1_000_000_000_000_000)

    XCTAssertEqual(oneQuadrillionAsString, oneQuadrillionAsDecimal)
  }

  public func testAddTwoWholeNumbers() {
    var left = Tez(3.0)
    let right = Tez(2.0)
    let expected = Tez(5.0)

    let actual = left + right
    XCTAssertEqual(actual, expected)

    left += right
    XCTAssertEqual(left, expected)
  }

  public func testAddTwoDecimalsNoCarry() {
    var left = Tez(1.1)
    let right = Tez(2.2)
    let expected = Tez(3.3)

    let actual = left + right
    XCTAssertEqual(actual, expected)

    left += right
    XCTAssertEqual(left, expected)
  }

  public func testAddTwoDecimalsWithCarry() {
    var left = Tez(1.6)
    let right = Tez(2.7)
    let expected = Tez(4.3)

    let actual = left + right
    XCTAssertEqual(actual, expected)

    left += right
    XCTAssertEqual(left, expected)
  }

  public func testSubtractTwoWholeNumbers() {
    var left = Tez(3.0)
    let right = Tez(2.0)
    let expected = Tez(1.0)

    let actual = left - right
    XCTAssertEqual(actual, expected)

    left -= right
    XCTAssertEqual(left, expected)
  }

  public func testSubtractTwoDecimalsNoCarry() {
    var left = Tez(3.3)
    let right = Tez(2.2)
    let expected = Tez(1.1)

    let actual = left - right
    XCTAssertEqual(actual, expected)

    left -= right
    XCTAssertEqual(left, expected)
  }

  public func testSubtractTwoDecimalsWithCarry() {
    var left = Tez(4.3)
    let right = Tez(1.6)
    let expected = Tez(2.7)

    let actual = left - right
    XCTAssertEqual(actual, expected)

    left -= right
    XCTAssertEqual(left, expected)
  }

  public func testGreaterThan() {
    XCTAssertTrue(Tez(1.0) > Tez(0.5))
    XCTAssertFalse(Tez(0.5) > Tez(1.0))
  }

  public func testLessThan() {
    XCTAssertFalse(Tez(1.0) < Tez(0.5))
    XCTAssertTrue(Tez(0.5) < Tez(1.0))
  }
}
