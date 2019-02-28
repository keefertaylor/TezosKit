// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

/// Integration tests to run against a live node running locally.
///
/// To get an alphanet node running locally, follow instructions here:
/// https://tezos.gitlab.io/alphanet/introduction/howtoget.html
///
/// These tests are not hermetic and may fail for a number or reasons, such as:
/// - Insufficient balance in account.
/// - Adverse network conditions.
///
/// Before running the tests, you should make sure that there's sufficient XTZ (~1XTZ) in the test account, which is:
/// https://alphanet.tzscan.io/tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW
///
/// You can check the balance of the account at:
/// https://tzscan.io/tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW
///
/// Instructions for adding balance to an alphanet account are available at:
/// https://tezos.gitlab.io/alphanet/introduction/howtouse.html#faucet

// TODO: Standardize throttle.
class TezosNodeIntegrationTests: XCTestCase {
  public static let timeout = 10.0
  public static let nodeURL = URL(string: "http://127.0.0.1:8732")!

  // TODO: migrate to test extension
  public static let testWallet =
    Wallet(mnemonic: "predict corn duty process brisk tomato shrimp virtual horror half rhythm cook")!

  public var nodeClient = TezosNodeClient()

  public override func setUp() {
    super.setUp()
    nodeClient = TezosNodeClient(remoteNodeURL: TezosNodeIntegrationTests.nodeURL)
  }

  public func testGetAccountBalance() {
    sleep(60)

    let expectation = XCTestExpectation(description: "completion called")

    nodeClient.getBalance(wallet: TezosNodeIntegrationTests.testWallet) { (result, error) in
      XCTAssertNotNil(result)
      XCTAssertNil(error)
      let balance = Double(result!.humanReadableRepresentation)!
      XCTAssertGreaterThan(balance, 0.0, "Balance in account was not greater than 0")

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: TezosNodeIntegrationTests.timeout)
  }

  public func testSend() {
    sleep(60)

    let expectation = XCTestExpectation(description: "completion called")

    self.nodeClient.send(
      amount: Tez("1")!,
      to: "tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5",
      from: TezosNodeIntegrationTests.testWallet.address,
      keys: TezosNodeIntegrationTests.testWallet.keys
    ) { (hash, error) in
      XCTAssertNotNil(hash)
      XCTAssertNil(error)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: TezosNodeIntegrationTests.timeout)
  }

  public func testRunOperation() {
    sleep(60)

    let expectation = XCTestExpectation(description: "completion called")

    let operation = OriginateAccountOperation(wallet: TezosNodeIntegrationTests.testWallet)
    self.nodeClient.estimateFees(operation, from: TezosNodeIntegrationTests.testWallet) { result, error in
      guard let result = result,
            let contents = result["contents"] as? [[String: Any]],
            let metadata = contents[0]["metadata"] as? [String: Any],
            let operationResult = metadata["operation_result"] as? [String: Any],
            let consumedGas = operationResult["consumed_gas"] as? String else {
              XCTFail()
              return
      }
      XCTAssertEqual(consumedGas, "10000")
      // TODO: Use consumed gas.
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: TezosNodeIntegrationTests.timeout)
  }

  public func testMultipleOperations() {
    let expectation = XCTestExpectation(description: "completion called")

    let ops: [TezosKit.Operation] = [
      TransactionOperation(
        amount: Tez("1")!,
        source: TezosNodeIntegrationTests.testWallet,
        destination: "tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5"
      ),
      TransactionOperation(
        amount: Tez("2")!,
        source: TezosNodeIntegrationTests.testWallet,
        destination: "tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5"
      )
    ]

    nodeClient.forgeSignPreapplyAndInject(
      ops,
      source: TezosNodeIntegrationTests.testWallet.address,
      keys: TezosNodeIntegrationTests.testWallet.keys
    ) { (hash: String?, error: Error?) in
      XCTAssertNil(error)
      XCTAssertNotNil(hash)

      expectation.fulfill()
    }
    wait(for: [expectation], timeout: TezosNodeIntegrationTests.timeout)
  }

  // TODO: Send multiple operatoins
}
