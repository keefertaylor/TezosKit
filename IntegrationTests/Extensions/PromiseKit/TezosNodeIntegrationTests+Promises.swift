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
      signatureProvider: Wallet.testWallet
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
    self.nodeClient.undelegate(from: Wallet.originatedAddress, signatureProvider: Wallet.testWallet).done { _ in
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
    let baker = Wallet()!
    let sendExpectation = XCTestExpectation(description: "sent xtz")
    self.nodeClient.send(
      amount: Tez(1),
      to: baker.address,
      from: Wallet.testWallet.address,
      signatureProvider: Wallet.testWallet
    ).done { _ in
      sendExpectation.fulfill()
    } .catch { _ in
        XCTFail()
    }
    wait(for: [sendExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Register the new account as a baker.
    let registerBakerExpectation = XCTestExpectation(description: "register baker")
    self.nodeClient.registerDelegate(delegate: baker.address, signatureProvider: baker).done { _ in
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
      signatureProvider: Wallet.testWallet
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
    self.nodeClient.undelegate(from: Wallet.originatedAddress, signatureProvider: Wallet.testWallet).done { _ in
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
      signatureProvider: Wallet.testWallet
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

    let operation = OperationFactory.testOperationFactory.originationOperation(
      address: Wallet.testWallet.address,
      operationFees: nil
    )
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
      signatureProvider: Wallet.testWallet
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
      OperationFactory.testOperationFactory.transactionOperation(
        amount: Tez("1")!,
        source: Wallet.testWallet.address,
        destination: "tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5",
        operationFees: nil
      ),
      OperationFactory.testOperationFactory.transactionOperation(
        amount: Tez("2")!,
        source: Wallet.testWallet.address,
        destination: "tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5",
        operationFees: nil
      )
    ]

    nodeClient.forgeSignPreapplyAndInject(
      operations: ops,
      source: Wallet.testWallet.address,
      signatureProvider: Wallet.testWallet
    ) .done { _ in
      expectation.fulfill()
    } .catch { _ in
      XCTFail()
    }
    wait(for: [expectation], timeout: .expectationTimeout)
  }

  func testSmartContractInvocation_promises() {
    let expectation = XCTestExpectation(description: "completion called")

    let operationFees = OperationFees(fee: Tez(1), gasLimit: 733_732, storageLimit: 0)
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
      operationFees: operationFees
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
