// Copyright Keefer Taylor, 2019.

@testable import TezosKit
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
/// https://alphanet.tzscan.io/tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW
///
/// Instructions for adding balance to an alphanet account are available at:
/// https://tezos.gitlab.io/alphanet/introduction/howtouse.html#faucet
///
/// These tests also utilize a token and Dexter Exchange contract, located at:
/// https://alphanet.tzscan.io/KT1RrfbcDM5eqho4j4u5EbqbaoEFwBsXA434
/// https://alphanet.tzscan.io/KT1Md4zkfCvkdqgxAC9tyRYpRUBKmD1owEi2
///
/// For more information about Dexter, see:
/// https://gitlab.com/camlcase-dev/dexter/blob/master/docs/dexter-cli.md

extension Wallet {
  // An address which has originated contracts on it.
  public static let contractOwningAddress = "tz1RYq8wjcCbRZykY7XH15WPkzK7TWwPvJJt"

  // An address of a Dexter Exchange Contract
  public static let dexterExchangeContract = "KT1RrfbcDM5eqho4j4u5EbqbaoEFwBsXA434"

  // An address of a token contract
  public static let tokenContract = "KT1Md4zkfCvkdqgxAC9tyRYpRUBKmD1owEi2"
}

extension URL {
  public static let nodeURL = URL(string: "https://tezos-dev.cryptonomic-infra.tech:443")!
}

extension UInt32 {
  // Time between blocks to wait for an operation to get included.
  public static let blockTime: UInt32 = 90
}

extension String {
  public static let testExpirationTimestamp = "2020-06-29T18:00:21Z"
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

  public func testDelegation() {
    // Clear any existing delegate.
    let undelegateExpectation = XCTestExpectation(description: "undelegate called")
    self.nodeClient.undelegate(
      from: Wallet.testWallet.address,
      signatureProvider: Wallet.testWallet,
      operationFeePolicy: .estimate
    ) { result in
      switch result {
      case .failure(let error):
        print(error)
        XCTFail()
      case .success:
        undelegateExpectation.fulfill()
      }
    }
    wait(for: [undelegateExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Validate the delegate cleared
    let checkDelegateClearedExpectation = XCTestExpectation(description: "check delegate cleared")
    self.nodeClient.getDelegate(address: Wallet.testWallet.address) { result in
      switch result {
      case .failure(let error):
        print(error)
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
      signatureProvider: Wallet.testWallet,
      operationFeePolicy: .estimate
    ) { result in
      switch result {
      case .failure(let error):
        print(error)
        XCTFail()
      case .success:
        sendExpectation.fulfill()
      }
    }
    wait(for: [sendExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Register the new account as a baker.
    let registerBakerExpectation = XCTestExpectation(description: "register baker")
    self.nodeClient.registerDelegate(
      delegate: baker.address,
      signatureProvider: baker,
      operationFeePolicy: .estimate
    ) { result in
      switch result {
      case .failure(let error):
        print(error)
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
      from: Wallet.testWallet.address,
      to: baker.address,
      signatureProvider: Wallet.testWallet,
      operationFeePolicy: .estimate
    ) { result in
      switch result {
      case .failure(let error):
        print(error)
        XCTFail()
      case .success:
        delegateToBakerExpectation.fulfill()
      }
    }
    wait(for: [delegateToBakerExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Validate the delegate set correctly
    let checkDelegateSetToBakerExpectation = XCTestExpectation(description: "delegated to baker")
    self.nodeClient.getDelegate(address: Wallet.testWallet.address) { result in
      switch result {
      case .failure(let error):
        print(error)
        XCTFail()
      case .success(let delegate):
        XCTAssertEqual(delegate, baker.address)
        checkDelegateSetToBakerExpectation.fulfill()
      }
    }
    wait(for: [checkDelegateSetToBakerExpectation], timeout: .expectationTimeout)

    // Clear the delegate
    let clearDelegateAfterDelegationExpectation = XCTestExpectation(description: "delegate cleared again")
    self.nodeClient.undelegate(
      from: Wallet.testWallet.address,
      signatureProvider: Wallet.testWallet,
      operationFeePolicy: .estimate
    ) { result in
      switch result {
      case .failure(let error):
        print(error)
        XCTFail()
      case .success:
        clearDelegateAfterDelegationExpectation.fulfill()
      }
    }
    wait(for: [clearDelegateAfterDelegationExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Validate the delegate cleared successfully
    let checkDelegateClearedAfterDelegationExpectation = XCTestExpectation(description: "check delegate cleared")
    self.nodeClient.getDelegate(address: Wallet.testWallet.address) { result in
      switch result {
      case .failure(let error):
        print(error)
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
      to: "tz1NBAfG9MpKxxWpaAXa52Y9XYh6Wdv77xG7",
      from: Wallet.testWallet.address,
      signatureProvider: Wallet.testWallet,
      operationFeePolicy: .estimate
    ) { result in
      switch result {
      case .failure(let error):
        XCTFail()
      case .success(let hash):
        print(hash)
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
      signatureProvider: Wallet.testWallet,
      operationFeePolicy: .estimate
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

    let operation = nodeClient.operationFactory.delegateOperation(
      source: Wallet.testWallet.address,
      to: "tz1RR6wETy9BeXG3Fjk25YmkSMGHxTtKkhpX",
      operationFeePolicy: .default,
      signatureProvider: Wallet.testWallet
    )!
    self.nodeClient.runOperation(operation, from: .testWallet) { result in
      switch result {
      case .failure(let error):
        print(error)
        XCTFail()
      case .success(let simulationResult):
        guard case .success(let consumedGas, let consumedStorage) = simulationResult else {
          XCTFail()
          return
        }
        XCTAssertEqual(consumedGas, 10_000)
        XCTAssertEqual(consumedStorage, 0)
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  public func testMultipleOperations() {
    let expectation = XCTestExpectation(description: "completion called")

    let ops: [TezosKit.Operation] = [
      nodeClient.operationFactory.transactionOperation(
        amount: Tez("1")!,
        source: Wallet.testWallet.address,
        destination: "tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5",
        operationFeePolicy: .default,
        signatureProvider: Wallet.testWallet
      )!,
      nodeClient.operationFactory.transactionOperation(
        amount: Tez("2")!,
        source: Wallet.testWallet.address,
        destination: "tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5",
        operationFeePolicy: .default,
        signatureProvider: Wallet.testWallet
      )!
    ]

    nodeClient.forgeSignPreapplyAndInject(
      ops,
      source: Wallet.testWallet.address,
      signatureProvider: Wallet.testWallet
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

  func testSmartContractInvocation() {
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
      amount: Tez(10.0),
      parameter: parameter,
      source: Wallet.testWallet.address,
      signatureProvider: Wallet.testWallet,
      operationFeePolicy: .estimate
    ) { result in
      switch result {
      case .failure(let error):
        print(error)
        XCTFail()
      case .success(let hash):
        print(hash)
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  func testGetBigMapValue() {
    let expectation = XCTestExpectation(description: "completion called")

    let parameter = StringMichelsonParameter(string: Wallet.testWallet.address)
    self.nodeClient.getBigMapValue(
      address: Wallet.tokenContract,
      key: parameter,
      type: .address
    ) { result in
      switch result {
      case .success(let result):
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
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  func testGetContractStorage() {
    let expectation = XCTestExpectation(description: "completion called")

    self.nodeClient.getContractStorage(address: Wallet.tokenContract) { result in
      switch result {
      case .success(let result):
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
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  // MARK: - Fee Estimation

  public func testDelegation_estimateFees() {
    // Clear any existing delegate.
    let undelegateExpectation = XCTestExpectation(description: "undelegate called")
    self.nodeClient.undelegate(
      from: Wallet.testWallet.address,
      signatureProvider: Wallet.testWallet,
      operationFeePolicy: .estimate
    ) { result in
      switch result {
      case .failure(let error):
        print(error)
        XCTFail()
      case .success(let hash):
        print(hash)
        undelegateExpectation.fulfill()
      }
    }
    wait(for: [undelegateExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Validate the delegate cleared
    let checkDelegateClearedExpectation = XCTestExpectation(description: "check delegate cleared")
    self.nodeClient.getDelegate(address: Wallet.testWallet.address) { result in
      switch result {
      case .failure(let error):
        print(error)
        // Expect a 404, see: https://gitlab.com/tezos/tezos/issues/490
        print("delegate cleared!")
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
      signatureProvider: Wallet.testWallet,
      operationFeePolicy: .estimate
    ) { result in
      switch result {
      case .failure(let error):
        print(error)
        XCTFail()
      case .success(let hash):
        print(hash)
        sendExpectation.fulfill()
      }
    }
    wait(for: [sendExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Register the new account as a baker.
    let registerBakerExpectation = XCTestExpectation(description: "register baker")
    self.nodeClient.registerDelegate(
      delegate: baker.address,
      signatureProvider: baker,
      operationFeePolicy: .estimate
    ) { result in
      switch result {
      case .failure(let error):
        print(error)
        XCTFail()
      case .success(let hash):
        print(hash)
        registerBakerExpectation.fulfill()
      }
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
    ) { result in
      switch result {
      case .failure(let error):
        print(error)
        XCTFail()
      case .success(let hash):
        print(hash)
        delegateToBakerExpectation.fulfill()
      }
    }
    wait(for: [delegateToBakerExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Validate the delegate set correctly
    let checkDelegateSetToBakerExpectation = XCTestExpectation(description: "delegated to baker")
    self.nodeClient.getDelegate(address: Wallet.testWallet.address) { result in
      switch result {
      case .failure(let error):
        print(error)
        XCTFail()
      case .success(let delegate):
        XCTAssertEqual(delegate, baker.address)
        checkDelegateSetToBakerExpectation.fulfill()
      }
    }
    wait(for: [checkDelegateSetToBakerExpectation], timeout: .expectationTimeout)

    // Clear the delegate
    let clearDelegateAfterDelegationExpectation = XCTestExpectation(description: "delegate cleared again")
    self.nodeClient.undelegate(
      from: Wallet.testWallet.address,
      signatureProvider: Wallet.testWallet,
      operationFeePolicy: .estimate
    ) { result in
      switch result {
      case .failure(let error):
        print(error)
        XCTFail()
      case .success(let hash):
        print("Undelegate success \(hash)")
        clearDelegateAfterDelegationExpectation.fulfill()
      }
    }
    wait(for: [clearDelegateAfterDelegationExpectation], timeout: .expectationTimeout)
    sleep(.blockTime)

    // Validate the delegate cleared successfully
    let checkDelegateClearedAfterDelegationExpectation = XCTestExpectation(description: "check delegate cleared")
    self.nodeClient.getDelegate(address: Wallet.testWallet.address) { result in
      switch result {
      case .failure(let error):
        print(error)
        // Expect a 404, see: https://gitlab.com/tezos/tezos/issues/490
        print("delegate is expectdly nil")
        checkDelegateClearedAfterDelegationExpectation.fulfill()
      case .success:
        XCTFail()
      }
    }
    wait(for: [checkDelegateClearedAfterDelegationExpectation], timeout: .expectationTimeout)
  }

  func testSmartContractInvocation_EstimateFees() {
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
      amount: Tez(100.0),
      parameter: parameter,
      source: Wallet.testWallet.address,
      signatureProvider: Wallet.testWallet,
      operationFeePolicy: .estimate
    ) { result in
      switch result {
      case .failure(let error):
        print(error)
        XCTFail()
      case .success(let hash):
        print(hash)
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  public func testSend_estimateFees() {
    let expectation = XCTestExpectation(description: "completion called")

    self.nodeClient.send(
      amount: Tez(1.0),
      to: Wallet()!.address,
      from: Wallet.testWallet.address,
      signatureProvider: Wallet.testWallet,
      operationFeePolicy: .estimate
    ) { result in
      switch result {
      case .failure(let error):
        print(error)
        XCTFail()
      case .success(let hash):
        print(hash)
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }
}
