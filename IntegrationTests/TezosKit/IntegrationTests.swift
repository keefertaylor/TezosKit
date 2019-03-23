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

extension Wallet {
  public static let testWallet =
    Wallet(mnemonic: "predict corn duty process brisk tomato shrimp virtual horror half rhythm cook")!
}

extension URL {
  public static let nodeURL = URL(string: "http://127.0.0.1:8732")!
}

extension Double {
  public static let expectationTimeout = 10.0
}

class TezosNodeIntegrationTests: XCTestCase {
  public var nodeClient = TezosNodeClient()

  public override func setUp() {
    super.setUp()

    /// Sending a bunch of requests quickly can cause race conditions in the Tezos network as counters and operations
    /// propagate. Define a throttle period in seconds to wait between each test.
    let intertestWaitTime: UInt32 = 30
    sleep(intertestWaitTime)

    nodeClient = TezosNodeClient(remoteNodeURL: .nodeURL)
  }

  public func testGetAccountBalance() {
    let expectation = XCTestExpectation(description: "completion called")

    nodeClient.getBalance(wallet: .testWallet) { result in
      switch result {
      case .failure:
        XCTFail()
      case .success(let balance):
        let humanReadableBalance = Double(balance.humanReadableRepresentation)!
        XCTAssertGreaterThan(humanReadableBalance, 0.0, "Balance in account was not greater than 0")
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  public func testSend() {
    let expectation = XCTestExpectation(description: "completion called")

    self.nodeClient.send(
      amount: Tez("1")!,
      to: "tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5",
      from: Wallet.testWallet.address,
      keys: Wallet.testWallet.keys
    ) { result in
      switch result {
      case .failure:
        XCTFail()
      case .success:
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  /// Preapplication should failure because of insufficient balance.
  public func testPreapplyFailure() {
    let expectation = XCTestExpectation(description: "completion called")

    self.nodeClient.send(
      amount: Tez("10000000000000")!,
      to: "tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5",
      from: Wallet.testWallet.address,
      keys: Wallet.testWallet.keys
    ) { result in
      switch result {
      case .failure:
        expectation.fulfill()
      case .success:
        XCTFail()
      }
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  public func testRunOperation() {
    let expectation = XCTestExpectation(description: "completion called")

    let operation = OriginateAccountOperation(wallet: .testWallet)
    self.nodeClient.runOperation(operation, from: .testWallet) { result in
      switch result {
      case .failure:
        XCTFail()
      case .success(let data):
        guard let contents = data["contents"] as? [[String: Any]],
              let metadata = contents[0]["metadata"] as? [String: Any],
              let operationResult = metadata["operation_result"] as? [String: Any],
              let consumedGas = operationResult["consumed_gas"] as? String else {
          XCTFail()
          return
        }
        XCTAssertEqual(consumedGas, "10000")
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  public func testMultipleOperations() {
    let expectation = XCTestExpectation(description: "completion called")

    let ops: [TezosKit.Operation] = [
      TransactionOperation(
        amount: Tez("1")!,
        source: .testWallet,
        destination: "tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5"
      ),
      TransactionOperation(
        amount: Tez("2")!,
        source: .testWallet,
        destination: "tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5"
      )
    ]

    nodeClient.forgeSignPreapplyAndInject(
      ops,
      source: Wallet.testWallet.address,
      keys: Wallet.testWallet.keys
    ) { result in
      switch result {
      case .failure:
        XCTFail()
      case .success:
        expectation.fulfill()
      }
    }
    wait(for: [expectation], timeout: .expectationTimeout)
  }
}
