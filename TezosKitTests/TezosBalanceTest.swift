import XCTest
import TezosKit

class TezosBalanceTest: XCTestCase {
	public func testHumanReadableRepresentationWithDecimalNumber() {
		guard let balanceFromString = TezosBalance(balance: "3500000") else {
			XCTFail()
			return
		}
		let balanceFromNumber = TezosBalance(balance: 3.50)

		XCTAssertEqual(balanceFromNumber.humanReadableRepresentation, "3.500000 ꜩ")
		XCTAssertEqual(balanceFromString.humanReadableRepresentation, "3.500000 ꜩ")
	}

	public func testRPCRepresentationWithDecimalNumber() {
		guard let balanceFromString = TezosBalance(balance: "3500000") else {
			XCTFail()
			return
		}
		let balanceFromNumber = TezosBalance(balance: 3.50)

		XCTAssertEqual(balanceFromNumber.rpcRepresentation, "3500000")
		XCTAssertEqual(balanceFromString.rpcRepresentation, "3500000")
	}

  public func testHumanReadableRepresentationWithWholeNumber() {
    guard let balanceFromString = TezosBalance(balance: "3000000") else {
      XCTFail()
      return
    }
    let balanceFromNumber = TezosBalance(balance: 3.00)

    XCTAssertEqual(balanceFromNumber.humanReadableRepresentation, "3.000000 ꜩ")
    XCTAssertEqual(balanceFromString.humanReadableRepresentation, "3.000000 ꜩ")
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
		XCTAssertEqual(balance.humanReadableRepresentation, "0.000035 ꜩ")
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
