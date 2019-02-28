// Copyright Keefer Taylor, 2019.

import PromiseKit
@testable import TezosKit
import XCTest

/// Integration tests for the Promises Extension.
/// Please see instructions in header of `IntegrationTests.swift`.
extension TezosNodeIntegrationTests {
  public func testGetAccountBalance_promises() {
    let expectation = XCTestExpectation(description: "completion called")

    nodeClient.getBalance(wallet: .testWallet).done { result in
      XCTAssertNotNil(result)
      let balance = Double(result.humanReadableRepresentation)!
      XCTAssertGreaterThan(balance, 0.0, "Balance in account was not greater than 0")
      expectation.fulfill()
    } .catch { _ in
        XCTFail()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  public func testSend_promises() {
    let expectation = XCTestExpectation(description: "completion called")

    nodeClient.send(
      amount: Tez("1")!,
      to: "tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5",
      from: Wallet.testWallet.address,
      keys: Wallet.testWallet.keys
    ) .done { hash in
      XCTAssertNotNil(hash)
      expectation.fulfill()
    } .catch { _ in
      XCTFail()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  // TODO: Enable
//  public func testRunOperation() {
//    let expectation = XCTestExpectation(description: "completion called")
//
//    let operation = OriginateAccountOperation(wallet: TezosNodeIntegrationTests.testWallet)
//    nodeClient.estimateFees(operation, from: TezosNodeIntegrationTests.testWallet) .done { result in
//      guard let result = result,
//        let contents = result["contents"] as? [[String: Any]],
//        let metadata = contents[0]["metadata"] as? [String: Any],
//        let operationResult = metadata["operation_result"] as? [String: Any],
//        let consumedGas = operationResult["consumed_gas"] as? String else {
//          XCTFail()
//          return
//      }
//      XCTAssertEqual(consumedGas, "10000")
//      expectation.fulfill()
//    }
//
//    wait(for: [expectation], timeout: TezosNodeIntegrationTests.expectationTimeout)
//  }
//
//  public func testMultipleOperations() {
//    let expectation = XCTestExpectation(description: "completion called")
//
//    let ops: [TezosKit.Operation] = [
//      TransactionOperation(
//        amount: Tez("1")!,
//        source: TezosNodeIntegrationTests.testWallet,
//        destination: "tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5"
//      ),
//      TransactionOperation(
//        amount: Tez("2")!,
//        source: TezosNodeIntegrationTests.testWallet,
//        destination: "tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5"
//      )
//    ]
//
//    nodeClient.forgeSignPreapplyAndInject(
//      ops,
//      source: TezosNodeIntegrationTests.testWallet.address,
//      keys: TezosNodeIntegrationTests.testWallet.keys
//    ) { (hash: String?, error: Error?) in
//      XCTAssertNil(error)
//      XCTAssertNotNil(hash)
//
//      expectation.fulfill()
//    }
//    wait(for: [expectation], timeout: TezosNodeIntegrationTests.expectationTimeout)
//  }
}
