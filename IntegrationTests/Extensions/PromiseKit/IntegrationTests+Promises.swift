// Copyright Keefer Taylor, 2019.

import PromiseKit
@testable import TezosKit
import XCTest

/// Integration tests for the Promises Extension.
/// Please see instructions in header of `IntegrationTests.swift`.
extension TezosNodeIntegrationTests {
  public func testGetAccountBalance_promises() {
    let expectation = XCTestExpectation(description: "completion called")

    nodeClient.getBalance(wallet: TezosNodeIntegrationTests.testWallet).done { result in
      XCTAssertNotNil(result)
      let balance = Double(result.humanReadableRepresentation)!
      XCTAssertGreaterThan(balance, 0.0, "Balance in account was not greater than 0")
      expectation.fulfill()
    } .catch { _ in
        XCTFail()
    }

    wait(for: [expectation], timeout: TezosNodeIntegrationTests.timeout)
  }

  public func testSend_promises() {
    let expectation = XCTestExpectation(description: "completion called")

    nodeClient.send(
      amount: Tez("1")!,
      to: "tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5",
      from: TezosNodeIntegrationTests.testWallet.address,
      keys: TezosNodeIntegrationTests.testWallet.keys
    ) .done { hash in
      XCTAssertNotNil(hash)
      XCTAssert(hash.hasPrefix("oo"))
      expectation.fulfill()
    } .catch { _ in
      XCTFail()
    }

    wait(for: [expectation], timeout: TezosNodeIntegrationTests.timeout)
  }
}
