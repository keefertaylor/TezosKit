// Copyright Keefer Taylor, 2019.

import BigInt
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
  public static let dexterExchangeContract = "KT1HrxtrCQ9ShddfCwExumteSXwR5Vp98EcS"

  // An address of a token contract
  public static let tokenContract = "KT1LKSFTrGSDNfVbWV4JXRrqGRD8XDSv5NAU"
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
    let intertestWaitTime: UInt32 = 0 // 120
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
        return
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
        return
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
        return
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
        return
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
        return
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
        return
      case .success(let delegate):
        XCTAssertEqual(delegate, baker.address)
        checkDelegateSetToBakerExpectation.fulfill()
      }
    }
    wait(for: [checkDelegateSetToBakerExpectation], timeout: .expectationTimeout)
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
      case .failure:
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
        XCTAssertEqual(error.kind, .transactionFormationFailure)
        expectation.fulfill()
      case .success:
        XCTFail()
      }
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }
//
//  public func testRunOperation() {
//    let expectation = XCTestExpectation(description: "completion called")
//
//    let operation = nodeClient.operationFactory.delegateOperation(
//      source: Wallet.testWallet.address,
//      to: .testnetBaker,
//      operationFeePolicy: .default,
//      signatureProvider: Wallet.testWallet
//    )!
//    self.nodeClient.runOperation(operation, from: .testWallet) { result in
//      switch result {
//      case .failure(let error):
//        print(error)
//        XCTFail()
//      case .success(let simulationResult):
//        guard case .success(let consumedGas, let consumedStorage) = simulationResult else {
//          XCTFail()
//          return
//        }
//        XCTAssertEqual(consumedGas, 10_000)
//        XCTAssertEqual(consumedStorage, 0)
//        expectation.fulfill()
//      }
//    }
//
//    wait(for: [expectation], timeout: .expectationTimeout)
//  }
//
//  public func testMultipleOperations() {
//    let expectation = XCTestExpectation(description: "completion called")
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
//      ops,
//      source: Wallet.testWallet.address,
//      signatureProvider: Wallet.testWallet
//    ) { result in
//      switch result {
//      case .failure:
//        XCTFail()
//      case .success:
//        expectation.fulfill()
//      }
//    }
//    wait(for: [expectation], timeout: .expectationTimeout)
//  }

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
          let firstArg = args[1] as? [String: Any],
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

    self.nodeClient.getContractStorage(address: Wallet.dexterExchangeContract) { result in
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

  public func testSend_tz2() {
    let expectation = XCTestExpectation(description: "completion called")

    let tz2Wallet = Wallet(secretKey: "spsk1fYtbGsvDEeb4NGanSiYQYcLFNZYNZ9F7jSvmCbT55DHcbtWjL", signingCurve: .secp256k1)!

    self.nodeClient.send(
      amount: Tez(1.0),
      to: "tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW",
      from: tz2Wallet.address,
      signatureProvider: tz2Wallet,
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

  public func testSend_tz3() {
    let expectation = XCTestExpectation(description: "completion called")

    let tz2Wallet = Wallet(secretKey: "p2sk3F598zRWQkdhYsuxHd1KgytsqvN9Gvn7RLqE24CMghJjDqFo54", signingCurve: .p256)!

    self.nodeClient.send(
      amount: Tez(1.0),
      to: "tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW",
      from: tz2Wallet.address,
      signatureProvider: tz2Wallet,
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

  public func testGetBigMapValueByID() {
    let expectation = XCTestExpectation(description: "Got big map value")

    self.nodeClient.getBigMapValue(
      bigMapID: BigInt(22),
      key: StringMichelsonParameter(string: "tz1bwsEWCwSEXdRvnJxvegQZKeX5dj6oKEys"),
      type: .address) { result in
      switch result {
      case .failure(let error):
        XCTFail("\(error)")
      case .success:
        expectation.fulfill()
      }
    }
    wait(for: [expectation], timeout: .expectationTimeout)
  }

  public func testPackData() {
    let expectation = XCTestExpectation(description: "completion called")
    let expected = "exprv6UsC1sN3Fk2XfgcJCL8NCerP5rCGy1PRESZAqr7L2JdzX55EN"
    let payload = PackDataPayload(
      michelsonParameter: StringMichelsonParameter(string: "tz1bwsEWCwSEXdRvnJxvegQZKeX5dj6oKEys"),
      michelsonComparable: .address
    )
    let rpc = PackDataRPC(payload: payload)

    self.nodeClient.run(rpc) { result in
      switch result {
      case .failure(let error):
        print(error)
        XCTFail()
      case .success(let hash):
        XCTAssertEqual(hash, expected)
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }
}
