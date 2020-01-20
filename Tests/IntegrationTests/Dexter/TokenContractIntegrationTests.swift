// Copyright Keefer Taylor, 2019.

@testable import TezosKit
import XCTest

/// Integration tests to run against a DEXter Token Contract. These tests require a live alphanet node.
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
/// Token Contract: https://better-call.dev/babylon/KT1U3cebEK95hbkg574qin45jLARg5PEV4yr
/// Address: https://babylonnet.tzstats.com/tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW

extension Address {
  public static let tokenContractAddress = "KT1U3cebEK95hbkg574qin45jLARg5PEV4yr"
  public static let tokenRecipient = "tz1XarY7qEahQBipuuNZ4vPw9MN6Ldyxv8G3"
}

extension Wallet {
  public static let tokenOwner =
    Wallet(mnemonic: "predict corn duty process brisk tomato shrimp virtual horror half rhythm cook")!
}

class TokenContractClientIntegrationTests: XCTestCase {
  public var nodeClient = TezosNodeClient()
  public var tokenContractClient = TokenContractClient(tokenContractAddress: .tokenContractAddress)

  public override func setUp() {
    super.setUp()

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
      to: Address.tokenRecipient,
      numTokens: 1,
      signatureProvider: Wallet.tokenOwner
    ) { result in
      switch result {
      case .success(let hash):
        print(hash)
        completionExpectation.fulfill()
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    wait(for: [ completionExpectation ], timeout: .expectationTimeout)
  }

  public func testApproveAllowanceTokens() {
    let completionExpectation = XCTestExpectation(description: "Completion called")

    tokenContractClient.approveAllowance(
      source: Wallet.tokenOwner.address,
      spender: Address.exchangeContractAddress,
      allowance: 500,
      signatureProvider: Wallet.tokenOwner
    ) { result in
      switch result {
      case .success(let hash):
        print(hash)
        completionExpectation.fulfill()
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    wait(for: [ completionExpectation ], timeout: .expectationTimeout)
  }

  public func testGetBalance() {
    let completionExpectation = XCTestExpectation(description: "Completion called")

    tokenContractClient.getTokenBalance(address: Wallet.tokenOwner.address) { result in
      guard case let .success(balance) = result else {
        XCTFail()
        return
      }

      XCTAssert(balance > 0)
      completionExpectation.fulfill()
    }
    wait(for: [ completionExpectation ], timeout: .expectationTimeout)
  }
}
