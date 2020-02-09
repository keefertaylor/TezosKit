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

  public func testDelegation_promises() {
    // Clear any existing delegate.
    let undelegateExpectation = XCTestExpectation(description: "undelegate called")
    self.nodeClient.undelegate(
      from: Wallet.testWallet.address,
      signatureProvider: Wallet.testWallet,
      operationFeePolicy: .estimate
    ).done { _ in
      undelegateExpectation.fulfill()
    } .catch { _ in
      XCTFail()
      return
    }
    wait(for: [undelegateExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Validate the delegate cleared
    let checkDelegateClearedExpectation = XCTestExpectation(description: "check delegate cleared")
    self.nodeClient.getDelegate(address: Wallet.testWallet.address).done { _ in
      XCTFail()
      return
    } .catch { _ in
      // Expect a 404, see: https://gitlab.com/tezos/tezos/issues/490
      checkDelegateClearedExpectation.fulfill()
    }
    wait(for: [checkDelegateClearedExpectation], timeout: .expectationTimeout)

    // Create a new account, send it some XTZ.
    let baker = Wallet()!
    let sendExpectation = XCTestExpectation(description: "sent xtz")
    self.nodeClient.send(
      amount: Tez(1),
      to: baker.address,
      from: Wallet.testWallet.address,
      signatureProvider: Wallet.testWallet,
      operationFeePolicy: .estimate
    ).done { _ in
      sendExpectation.fulfill()
    } .catch { _ in
      XCTFail()
      return
    }
    wait(for: [sendExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Register the new account as a baker.
    let registerBakerExpectation = XCTestExpectation(description: "register baker")
    self.nodeClient.registerDelegate(
      delegate: baker.address,
      signatureProvider: baker,
      operationFeePolicy: .estimate
    ).done { _ in
      registerBakerExpectation.fulfill()
    } .catch { _ in
      XCTFail()
      return
    }
    wait(for: [registerBakerExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Delegate to the new baker.
    let delegateToBakerExpectation = XCTestExpectation(description: "delegated")
    self.nodeClient.delegate(
      from: Wallet.testWallet.address,
      to: baker.address,
      signatureProvider: Wallet.testWallet,
      operationFeePolicy: .estimate
    ).done { _ in
      delegateToBakerExpectation.fulfill()
    } .catch { _ in
      XCTFail()
      return
    }
    wait(for: [delegateToBakerExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Validate the delegate set correctly
    let checkDelegateSetToBakerExpectation = XCTestExpectation(description: "delegated to baker")
    self.nodeClient.getDelegate(address: Wallet.testWallet.address).done { delegate in
      XCTAssertEqual(delegate, baker.address)
      checkDelegateSetToBakerExpectation.fulfill()
    } .catch { _ in
      XCTFail()
      return
    }
    wait(for: [checkDelegateSetToBakerExpectation], timeout: .expectationTimeout)

    // Clear the delegate
    let clearDelegateAfterDelegationExpectation = XCTestExpectation(description: "delegate cleared again")
    self.nodeClient.undelegate(
      from: Wallet.testWallet.address,
      signatureProvider: Wallet.testWallet,
      operationFeePolicy: .estimate
    ).done { _ in
      clearDelegateAfterDelegationExpectation.fulfill()
    } .catch { _ in
      XCTFail()
      return
    }
    wait(for: [clearDelegateAfterDelegationExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)
  }

  public func testSend_promises() {
    let expectation = XCTestExpectation(description: "completion called")

    nodeClient.send(
      amount: Tez("1")!,
      to: "tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5",
      from: Wallet.testWallet.address,
      signatureProvider: Wallet.testWallet,
      operationFeePolicy: .estimate
    ) .done { hash in
      XCTAssertNotNil(hash)
      expectation.fulfill()
    } .catch { _ in
      XCTFail()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }
//
//  public func testRunOperation_promises() {
//    let expectation = XCTestExpectation(description: "completion called")
//
//    let operation = nodeClient.operationFactory.delegateOperation(
//      source: Wallet.testWallet.address,
//      to: .testnetBaker,
//      operationFeePolicy: .default,
//      signatureProvider: Wallet.testWallet
//    )!
//    self.nodeClient.runOperation(operation, from: .testWallet).done { simulationResult in
//      guard case .success(let consumedGas, let consumedStorage) = simulationResult else {
//        XCTFail()
//        return
//      }
//      XCTAssertEqual(consumedGas, 10_000)
//      XCTAssertEqual(consumedStorage, 0)
//      expectation.fulfill()
//    } .catch { _ in
//        XCTFail()
//    }
//
//    wait(for: [expectation], timeout: .expectationTimeout)
//  }

  /// Preapplication should failure because of insufficient balance.
  public func testPreapplyFailure_promises() {
    let expectation = XCTestExpectation(description: "completion called")

    nodeClient.send(
      amount: Tez("10000000000000")!,
      to: "tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5",
      from: Wallet.testWallet.address,
      signatureProvider: Wallet.testWallet,
      operationFeePolicy: .estimate
    ).done { _ in
      XCTFail()
    } .catch { error in
      guard let tezosKitError = error as? TezosKitError else {
        XCTFail()
        return
      }
      XCTAssertEqual(tezosKitError.kind, .transactionFormationFailure)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }
//
//  public func testMultipleOperations_promises() {
//    let expectation = XCTestExpectation(description: "promise fulfilled")
//
//    let ops: [TezosKit.Operation] = [
//      nodeClient.operationFactory.transactionOperation(
//        amount: Tez("1")!,
//        source: Wallet.testWallet.address,
//        destination: "tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5",
//        operationFeePolicy: .estimate,
//        signatureProvider: Wallet.testWallet
//      )!,
//      nodeClient.operationFactory.transactionOperation(
//        amount: Tez("2")!,
//        source: Wallet.testWallet.address,
//        destination: "tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5",
//        operationFeePolicy: .estimate,
//        signatureProvider: Wallet.testWallet
//      )!
//    ]
//
//    nodeClient.forgeSignPreapplyAndInject(
//      operations: ops,
//      source: Wallet.testWallet.address,
//      signatureProvider: Wallet.testWallet
//    ) .done { _ in
//      expectation.fulfill()
//    } .catch { error in
//      XCTFail("\(error)")
//    }
//    wait(for: [expectation], timeout: .expectationTimeout)
//  }

  func testSmartContractInvocation_promises() {
    let expectation = XCTestExpectation(description: "completion called")

    let parameter =
      RightMichelsonParameter(
        arg: LeftMichelsonParameter(
          arg: PairMichelsonParameter(
            left: IntMichelsonParameter(int: 1),
            right: StringMichelsonParameter(string: .testExpirationTimestamp)
          )
        )
    )

    self.nodeClient.call(
      contract: Wallet.dexterExchangeContract,
      amount: Tez(1.0),
      parameter: parameter,
      source: Wallet.testWallet.address,
      signatureProvider: Wallet.testWallet,
      operationFeePolicy: .estimate
    ) .done { _ in
      expectation.fulfill()
    } .catch { _ in
      XCTFail()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  func testGetBigMapValue_promises() {
    let expectation = XCTestExpectation(description: "completion called")

    let parameter = StringMichelsonParameter(string: Wallet.testWallet.address)
    self.nodeClient.getBigMapValue(
      address: Wallet.tokenContract,
      key: parameter,
      type: .address
    ) .done { result in
      guard
        let args = result["args"] as? [Any],
        let firstArg = args[0] as? [String: Any],
        let valueString = firstArg["int"] as? String,
        let value = Int(valueString)
      else {
        XCTFail()
        return
      }
      XCTAssert(value > 0)
      expectation.fulfill()
    } .catch { _ in
      XCTFail()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  func testGetContractStorage_promises() {
    let expectation = XCTestExpectation(description: "completion called")

    self.nodeClient.getContractStorage(address: Wallet.tokenContract) .done { result in
      guard
        let args = result["args"] as? [Any],
        let args2 = args[1] as? [String: Any],
        let args3 = args2["args"] as? [Any],
        let args4 = args3[1] as? [String: Any],
        let args5 = args4["args"] as? [Any],
        let args6 = args5[1] as? [String: Any],
        let ticker = args6["string"] as? String
      else {
        XCTFail()
        return
      }

      XCTAssertEqual(ticker, "TGD")
      expectation.fulfill()
    } .catch { _ in
      XCTFail()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }
}
