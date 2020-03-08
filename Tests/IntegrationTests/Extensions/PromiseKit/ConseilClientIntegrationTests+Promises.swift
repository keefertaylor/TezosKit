// Copyright Keefer Taylor, 2019

import Foundation
import PromiseKit
import TezosKit
import XCTest

/// Integration tests for the ConseilClient Promises Extension.
/// Please see instructions in header of `ConseilClientIntegrationTests.swift`.
extension ConseilClientIntegrationTests {
  func testGetTransactionsReceived_promises() {
    let expectation = XCTestExpectation(description: "promise fulfilled")

    conseilClient.transactionsReceived(from: Wallet.testWallet.address).done { result in
      XCTAssertNotNil(result)
      XCTAssert(result.count > 1)
      expectation.fulfill()
    } .catch { _ in
      XCTFail()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  func testGetTransactionsSent_promises() {
    let expectation = XCTestExpectation(description: "promise fulfilled")

    conseilClient.transactionsSent(from: Wallet.testWallet.address).done { result in
      XCTAssertNotNil(result)
      XCTAssert(result.count > 1)
      expectation.fulfill()
    } .catch { _ in
      XCTFail()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  func testGetTransactions_promises() {
    let expectation = XCTestExpectation(description: "promise fulfilled")

    conseilClient.transactions(from: Wallet.testWallet.address).done { result in
      XCTAssertNotNil(result)
      XCTAssert(result.count > 1)
      expectation.fulfill()
    } .catch { _ in
        XCTFail()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  func testGetOriginatedAccounts_promises() {
    let expectation = XCTestExpectation(description: "promise fulfilled")
    conseilClient.originatedAccounts(from: Wallet.testWallet.address).done { result in
      XCTAssertNotNil(result)
      XCTAssert(result.count > 1)
      expectation.fulfill()
    } .catch { _ in
        XCTFail()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  func testGetOriginatedContracts_promises() {
    let expectation = XCTestExpectation(description: "promise fulfilled")
    conseilClient.originatedContracts(from: Wallet.contractOwningAddress).done { result in
      XCTAssertNotNil(result)
      XCTAssert(result.count > 1)
      expectation.fulfill()
    } .catch { _ in
        XCTFail()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }
}
