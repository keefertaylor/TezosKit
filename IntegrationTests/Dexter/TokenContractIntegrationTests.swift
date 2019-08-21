// Copyright Keefer Taylor, 2019.

@testable import TezosKit
import XCTest

/// Integration tests to run against a Dexter Token Contract. These tests require a live alphanet node.
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
/// https://alphanet.tzscan.io/KT1PARMPddZ9WD1MPmPthXYBCgErmxAHKBD8

extension Address {
  public static let tokenContractAddress = "KT1PARMPddZ9WD1MPmPthXYBCgErmxAHKBD8"
}

extension Wallet {
  public static let tokenOwner =
    Wallet(mnemonic: "predict corn duty process brisk tomato shrimp virtual horror half rhythm cook")!
  public static let tokenRecipient =
    Wallet(mnemonic: "over retreat table edge spawn weather curve issue risk you autumn shy garage wheat zone")!
}

class TokenContractClientIntegrationTests: XCTestCase {
  public var nodeClient = TezosNodeClient()
  public var tokenContractClient = TokenContractClient(tokenContractAddress: "")

  public override func setUp() {
    super.setUp()

    /// Sending a bunch of requests quickly can cause race conditions in the Tezos network as counters and operations
    /// propagate. Define a throttle period in seconds to wait between each test.
    let intertestWaitTime: UInt32 = 30
    sleep(intertestWaitTime)

    let nodeClient = TezosNodeClient(remoteNodeURL: .nodeURL)
    tokenContractClient = TokenContractClient(
      tokenContractAddress: .tokenContractAddress,
      tezosNodeClient: nodeClient
    )
  }

  public func testTransferTokens() {
    let completionExpectation = XCTestExpectation(description: "Completion called")

    tokenContractClient.transferTokens(
      from: Wallet.tokenOwner.address,
      to: Wallet.tokenRecipient.address,
      numTokens: 1,
      signatureProvider: Wallet.tokenOwner
    ) { result in
      switch result {
      case .success(let hash):
        print("operation hash: \(hash)")
        completionExpectation.fulfill()
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    wait(for: [ completionExpectation ], timeout: .expectationTimeout)
  }

  public func testGetBalance() {

  }
}
