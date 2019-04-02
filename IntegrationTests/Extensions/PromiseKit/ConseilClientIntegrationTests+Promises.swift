// Copyright Keefer Taylor, 2019

import Foundation

// TODO: Extension
// TODO: File name
/// Integration tests for the ConseilClient Promises Extension.
/// Please see instructions in header of `ConseilClientIntegrationTests.swift`.
final class ConseilClientIntegrationTests: XCTestCase {
}

extension ConseilClientIntegrationTests {
  func testGetTransactionsReceived_promises() {
    let expectation = XCTestExpectation(description: "promise fulfilled")

    conseilClient.transactionsReceived(account: Wallet.testWallet.address).done { result in
      XCTAssertNotNil(result)
      expectation.fulfill()
    } .catch { _ in
      XCTFail()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  func testGetTransactionsSent_promises() {
    let expectation = XCTestExpectation(description: "promise fulfilled")

    conseilClient.transactionsSent(account: Wallet.testWallet.address).done { result in
      XCTAssertNotNil(result)
      expectation.fulfill()
    } .catch { _ in
      XCTFail()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }
}
