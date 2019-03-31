// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

// swiftlint:disable cyclomatic_complexity
// swiftlint:disable identifier_name

/// Integration tests to run against a live node running locally.
///
/// To get an alphanet node running locally, follow instructions here:
/// https://tezos.gitlab.io/alphanet/introduction/howtoget.html
///
/// These tests are not hermetic and may fail for a number or reasons, such as:
/// - Insufficient balance in account.
/// - Adverse network conditions.
///
/// Before running the tests, you should make sure that there's sufficient XTZ (~100XTZ) in the test account, which is:
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
  public static let originatedAddress = "KT1D5jmrBD7bDa3jCpgzo32FMYmRDdK2ihka"
}

extension URL {
  public static let nodeURL = URL(string: "http://127.0.0.1:8732")!
}

extension Double {
  public static let expectationTimeout = 10.0
}

extension UInt32 {
  // Time between blocks to wait for an operation to get included.
  public static let blockTime: UInt32 = 120
}

class TezosNodeIntegrationTests: XCTestCase {
  public var nodeClient = TezosNodeClient()

  public override func setUp() {
    super.setUp()

    /// Sending a bunch of requests quickly can cause race conditions in the Tezos network as counters and operations
    /// propagate. Define a throttle period in seconds to wait between each test.
    let intertestWaitTime: UInt32 = 0
    sleep(intertestWaitTime)

    nodeClient = TezosNodeClient(remoteNodeURL: .nodeURL)
  }

  public func testConseilSent() {
    let apiKey = "hooman"
    let remoteNodeURL = URL(string: "https://conseil-dev.cryptonomic-infra.tech:443")!
    let conseilClient = ConseilClient(remoteNodeURL: remoteNodeURL, apiKey: apiKey, network: .alphanet)

    let expectation = XCTestExpectation(description: "completion called")
    conseilClient.transactionsSent(from: Wallet.testWallet.address) { result in
      switch result {
      case .success(let result):
        print(result)
        expectation.fulfill()
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }
    wait(for: [expectation], timeout: .expectationTimeout)
  }

  public func testConseilReceived() {
    let apiKey = "hooman"
    let remoteNodeURL = URL(string: "https://conseil-dev.cryptonomic-infra.tech:443")!
    let conseilClient = ConseilClient(remoteNodeURL: remoteNodeURL, apiKey: apiKey, network: .alphanet)

    let expectation = XCTestExpectation(description: "completion called")
    conseilClient.transactionsReceived(from: Wallet.testWallet.address) { result in
      switch result {
      case .success(let result):
        print(result)
        expectation.fulfill()
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }
    wait(for: [expectation], timeout: .expectationTimeout)
  }
//
//  public func testConseilAllTX() {
//      let apiKey = "hooman"
//      let remoteNodeURL = URL(string: "https://conseil-dev.cryptonomic-infra.tech:443")!
//      let conseilClient = ConseilClient(remoteNodeURL: remoteNodeURL, apiKey: apiKey, network: .alphanet)
//
//      let expectation = XCTestExpectation(description: "completion called")
//      conseilClient.transactions(from: Wallet.testWallet.address) { result in
//        switch result {
//        case .success(let results):
//          for result in results {
//            print(result)
//          }
//          expectation.fulfill()
//        case .failure(let error):
//          print(error)
//          XCTFail()
//        }
//      }
//      wait(for: [expectation], timeout: .expectationTimeout)
//
//  }

  public func testOriginations() {
    let apiKey = "hooman"
    let remoteNodeURL = URL(string: "https://conseil-dev.cryptonomic-infra.tech:443")!
    let conseilClient = ConseilClient(remoteNodeURL: remoteNodeURL, apiKey: apiKey, network: .alphanet)

    let expectation = XCTestExpectation(description: "completion called")
    conseilClient.originatedAccounts(from: Wallet.testWallet.address) { result in
      switch result {
      case .success(let results):
        for result in results {
          print(result)
        }
        expectation.fulfill()
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }
    wait(for: [expectation], timeout: .expectationTimeout)

  }

  public func testOrigination() {
    let expectation = XCTestExpectation(description: "completion called")

    self.nodeClient.originateAccount(
      managerAddress: Wallet.testWallet.address,
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

  public func testDelegation() {
    // Clear any existing delegate.
    let undelegateExpectation = XCTestExpectation(description: "undelegate called")
    self.nodeClient.undelegate(from: Wallet.originatedAddress, keys: Wallet.testWallet.keys) { result in
      switch result {
      case .failure:
        XCTFail()
      case .success:
        undelegateExpectation.fulfill()
      }
    }
    wait(for: [undelegateExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Validate the delegate cleared
    let checkDelegateClearedExpectation = XCTestExpectation(description: "check delegate cleared")
    self.nodeClient.getDelegate(address: Wallet.originatedAddress) { result in
      switch result {
      case .failure:
        // Expect a 404, see: https://gitlab.com/tezos/tezos/issues/490
        checkDelegateClearedExpectation.fulfill()
      case .success:
        XCTFail()
      }
    }
    wait(for: [checkDelegateClearedExpectation], timeout: .expectationTimeout)

    // Create a new account, send it some XTZ.
    let baker = Wallet()!
    let sendExpectation = XCTestExpectation(description: "sent xtz")
    self.nodeClient.send(
      amount: Tez(1),
      to: baker.address,
      from: Wallet.testWallet.address,
      keys: Wallet.testWallet.keys
    ) { result in
      switch result {
      case .failure:
        XCTFail()
      case .success:
        sendExpectation.fulfill()
      }
    }
    wait(for: [sendExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Register the new account as a baker.
    let registerBakerExpectation = XCTestExpectation(description: "register baker")
    self.nodeClient.registerDelegate(delegate: baker.address, keys: baker.keys) { result in
      switch result {
      case .failure:
        XCTFail()
      case .success:
        registerBakerExpectation.fulfill()
      }
    }
    wait(for: [registerBakerExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Delegate to the new baker.
    let delegateToBakerExpectation = XCTestExpectation(description: "delegated")
    self.nodeClient.delegate(
      from: Wallet.originatedAddress,
      to: baker.address,
      keys: Wallet.testWallet.keys
    ) { result in
      switch result {
      case .failure:
        XCTFail()
      case .success:
        delegateToBakerExpectation.fulfill()
      }
    }
    wait(for: [delegateToBakerExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Validate the delegate set correctly
    let checkDelegateSetToBakerExpectation = XCTestExpectation(description: "delegated to baker")
    self.nodeClient.getDelegate(address: Wallet.originatedAddress) { result in
      switch result {
      case .failure:
        XCTFail()
      case .success(let delegate):
        XCTAssertEqual(delegate, baker.address)
        checkDelegateSetToBakerExpectation.fulfill()
      }
    }
    wait(for: [checkDelegateSetToBakerExpectation], timeout: .expectationTimeout)

    // Clear the delegate
    let clearDelegateAfterDelegationExpectation = XCTestExpectation(description: "delegate cleared again")
    self.nodeClient.undelegate(from: Wallet.originatedAddress, keys: Wallet.testWallet.keys) { result in
      switch result {
      case .failure:
        XCTFail()
      case .success:
        clearDelegateAfterDelegationExpectation.fulfill()
      }
    }
    wait(for: [clearDelegateAfterDelegationExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Validate the delegate cleared successfully
    let checkDelegateClearedAfterDelegationExpectation = XCTestExpectation(description: "check delegate cleared")
    self.nodeClient.getDelegate(address: Wallet.originatedAddress) { result in
      switch result {
      case .failure:
        // Expect a 404, see: https://gitlab.com/tezos/tezos/issues/490
        checkDelegateClearedAfterDelegationExpectation.fulfill()
      case .success:
        XCTFail()
      }
    }
    wait(for: [checkDelegateClearedAfterDelegationExpectation], timeout: .expectationTimeout)

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
      amount: Tez("10000000")!,
      to: "KT1D5jmrBD7bDa3jCpgzo32FMYmRDdK2ihka",
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
      case .failure(let error):
        XCTAssertEqual(error.kind, .preapplicationError)
        XCTAssert(error.underlyingError!.contains("balance_too_low"))
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
