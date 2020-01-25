// Copyright Keefer Taylor, 2019.

import PromiseKit
@testable import TezosKit
import XCTest

// swiftlint:disable identifier_name

/// Integration tests for the Promises Extension.
/// Please see instructions in header of `TezosNodeIntegrationTests.swift`.
extension TezosNodeIntegrationTests {
  public func testGetAccountBalance_promises() {
    let expectation = XCTestExpectation(description: "promise fulfilled")

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

  public func testOrigination_promises() {
    let expectation = XCTestExpectation(description: "promise fulfilled")

    self.nodeClient.originateAccount(
      managerAddress: Wallet.testWallet.address,
      keys: Wallet.testWallet.keys
    ).done { hash in
      XCTAssertNotNil(hash)
      expectation.fulfill()
    } .catch { _ in
      XCTFail()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  public func testDelegation_promises() {
    // Clear any existing delegate.
    let undelegateExpectation = XCTestExpectation(description: "undelegate called")
    self.nodeClient.undelegate(from: Wallet.originatedAddress, keys: Wallet.testWallet.keys).done { _ in
      undelegateExpectation.fulfill()
    } .catch { _ in
        XCTFail()
    }
    wait(for: [undelegateExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Validate the delegate cleared
    let checkDelegateClearedExpectation = XCTestExpectation(description: "check delegate cleared")
    self.nodeClient.getDelegate(address: Wallet.originatedAddress).done { _ in
      XCTFail()
    } .catch { _ in
      // Expect a 404, see: https://gitlab.com/tezos/tezos/issues/490
      checkDelegateClearedExpectation.fulfill()
    }
    wait(for: [checkDelegateClearedExpectation], timeout: .expectationTimeout)

    // Create a new account, send it some XTZ.
    let baker = Wallet(signingCurve: .ed25519)!
    let sendExpectation = XCTestExpectation(description: "sent xtz")
    self.nodeClient.send(
      amount: Tez(1),
      to: baker.address,
      from: Wallet.testWallet.address,
      keys: Wallet.testWallet.keys
    ).done { _ in
      sendExpectation.fulfill()
    } .catch { _ in
        XCTFail()
    }
    wait(for: [sendExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Register the new account as a baker.
    let registerBakerExpectation = XCTestExpectation(description: "register baker")
    self.nodeClient.registerDelegate(delegate: baker.address, keys: baker.keys).done { _ in
      registerBakerExpectation.fulfill()
    } .catch { _ in
      XCTFail()
    }
    wait(for: [registerBakerExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Delegate to the new baker.
    let delegateToBakerExpectation = XCTestExpectation(description: "delegated")
    self.nodeClient.delegate(
      from: Wallet.originatedAddress,
      to: baker.address,
      keys: Wallet.testWallet.keys
    ).done { _ in
      delegateToBakerExpectation.fulfill()
    } .catch { _ in
      XCTFail()
    }
    wait(for: [delegateToBakerExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Validate the delegate set correctly
    let checkDelegateSetToBakerExpectation = XCTestExpectation(description: "delegated to baker")
    self.nodeClient.getDelegate(address: Wallet.originatedAddress).done { delegate in
      XCTAssertEqual(delegate, baker.address)
      checkDelegateSetToBakerExpectation.fulfill()
    } .catch { _ in
      XCTFail()
    }
    wait(for: [checkDelegateSetToBakerExpectation], timeout: .expectationTimeout)

    // Clear the delegate
    let clearDelegateAfterDelegationExpectation = XCTestExpectation(description: "delegate cleared again")
    self.nodeClient.undelegate(from: Wallet.originatedAddress, keys: Wallet.testWallet.keys).done { _ in
      clearDelegateAfterDelegationExpectation.fulfill()
    } .catch { _ in
      XCTFail()
    }
    wait(for: [clearDelegateAfterDelegationExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Validate the delegate cleared successfully
    let checkDelegateClearedAfterDelegationExpectation = XCTestExpectation(description: "check delegate cleared")
    self.nodeClient.getDelegate(address: Wallet.originatedAddress).done { _ in
      XCTFail()
    } .catch { _ in
      // Expect a 404, see: https://gitlab.com/tezos/tezos/issues/490
      checkDelegateClearedAfterDelegationExpectation.fulfill()
    }

    wait(for: [checkDelegateClearedAfterDelegationExpectation], timeout: .expectationTimeout)
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

  public func testRunOperation_promises() {
    let expectation = XCTestExpectation(description: "completion called")

    let operation = OriginateAccountOperation(wallet: .testWallet)
    nodeClient.runOperation(operation, from: .testWallet) .done { result in
      guard let contents = result["contents"] as? [[String: Any]],
            let metadata = contents[0]["metadata"] as? [String: Any],
            let operationResult = metadata["operation_result"] as? [String: Any],
            let consumedGas = operationResult["consumed_gas"] as? String else {
          XCTFail()
          return
      }
      XCTAssertEqual(consumedGas, "10000")
      expectation.fulfill()
    } .catch { _ in
      XCTFail()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  /// Preapplication should failure because of insufficient balance.
  public func testPreapplyFailure_promises() {
    let expectation = XCTestExpectation(description: "completion called")

    nodeClient.send(
      amount: Tez("10000000000000")!,
      to: "tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5",
      from: Wallet.testWallet.address,
      keys: Wallet.testWallet.keys
    ).done { _ in
      XCTFail()
    } .catch { error in
      guard let tezosKitError = error as? TezosKitError else {
        XCTFail()
        return
      }
      XCTAssertEqual(tezosKitError.kind, .preapplicationError)
      XCTAssert(tezosKitError.underlyingError!.contains("balance_too_low"))
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  public func testMultipleOperations_promises() {
    let expectation = XCTestExpectation(description: "promise fulfilled")

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
      operations: ops,
      source: Wallet.testWallet.address,
      keys: Wallet.testWallet.keys
    ) .done { _ in
      expectation.fulfill()
    } .catch { _ in
      XCTFail()
    }
    wait(for: [expectation], timeout: .expectationTimeout)
  }
}
