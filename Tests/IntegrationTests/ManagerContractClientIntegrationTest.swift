// Copyright Keefer Taylor, 2019.

@testable import TezosKit
import XCTest

/// Integration tests to run against a Manager.tz Contract. These tests require a live alphanet node.
///
/// To get an alphanet node running locally, follow instructions here:
/// https://tezos.gitlab.io/alphanet/introduction/howtoget.html
///
/// These tests are not hermetic and may fail for a number or reasons, such as:
/// - Insufficient balance in account.
/// - Adverse network conditions.
///
/// Before running the tests, you should make sure that there's sufficient tokens in the owners account (which is
/// tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW) in the token contract at:
/// Token Contract: https://better-call.dev/babylon/KT1VPVdNiWskBEVHF3pWdxyxepj4ZaWTGKgz/script
/// Address: https://babylonnet.tzstats.com/tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW

extension Address {
  public static let managerContractAddress = "KT1VPVdNiWskBEVHF3pWdxyxepj4ZaWTGKgz"
  public static let managerContractDelegate = "tz1aNJyLu5HbwjKv1e6msaEQoTPy9tv6d9oE"
}

class ManagerContractClientIntegrationTests: XCTestCase {
  public var nodeClient: TezosNodeClient!
  public var managerClient: ManagerClient!

  public override func setUp() {
    super.setUp()

    let nodeClient = TezosNodeClient(remoteNodeURL: .nodeURL)
    managerClient = ManagerClient(
      contractAddress: .managerContractAddress,
      tezosNodeClient: nodeClient
    )
  }

  public func testDelegate() {
    let completionExpectation = XCTestExpectation(description: "Completion called")

    self.managerClient.delegate(
      to: .managerContractDelegate,
      signatureProvider: Wallet.testWallet
    ) { result in
      switch result {
      case .success:
        completionExpectation.fulfill()
      case .failure:
        XCTFail()
      }
    }

    wait(for: [ completionExpectation ], timeout: .expectationTimeout)
  }

  public func testUndelegate() {
    let completionExpectation = XCTestExpectation(description: "Completion called")

    self.managerClient.undelegate(
      signatureProvider: Wallet.testWallet
    ) { result in
      switch result {
      case .success:
        completionExpectation.fulfill()
      case .failure:
        XCTFail()
      }
    }

    wait(for: [ completionExpectation ], timeout: .expectationTimeout)
  }

  public func testTransfer() {
    let completionExpectation = XCTestExpectation(description: "Completion called")

    self.managerClient.transfer(
      to: Wallet.testWallet.address,
      amount: Tez(0.5),
      signatureProvider: Wallet.testWallet
    ) { result in
      switch result {
      case .success:
        completionExpectation.fulfill()
      case .failure:
        XCTFail()
      }
    }

    wait(for: [ completionExpectation ], timeout: .expectationTimeout)
  }
}
