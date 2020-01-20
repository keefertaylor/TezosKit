// Copyright Keefer Taylor, 2019.

@testable import TezosKit
import XCTest

/// Integration tests to run against a DEXter Exchange Contract. These tests require a live alphanet node.
///
/// To get an alphanet node running locally, follow instructions here:
/// https://tezos.gitlab.io/alphanet/introduction/howtoget.html
///
/// These tests are not hermetic and may fail for a number or reasons, such as:
/// - Insufficient balance in account.
/// - Adverse network conditions.
///
/// Before running the tests, you should make sure that there's sufficient tokens in the owners account (which is
/// tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW) and liquidity in the exchange:
/// Exchange: https://better-call.dev/babylon/KT1DWDmibBTERCxFpTZXwi42AeF5Ug82vjto
/// Address: https://babylonnet.tzstats.com/tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW

extension Address {
  public static let exchangeContractAddress = "KT1DWDmibBTERCxFpTZXwi42AeF5Ug82vjto"
}

class DexterExchangeClientIntegrationTests: XCTestCase {
  public var nodeClient = TezosNodeClient()
  public var exchangeClient = DexterExchangeClient(exchangeContractAddress: "")

  public override func setUp() {
    super.setUp()

    let nodeClient = TezosNodeClient(remoteNodeURL: .nodeURL)
    exchangeClient = DexterExchangeClient(
      exchangeContractAddress: .exchangeContractAddress,
      tezosNodeClient: nodeClient
    )
  }

  public func testGetBalanceTez() {
    let completionExpectation = XCTestExpectation(description: "Completion called")

    exchangeClient.getExchangeBalanceTez { result in
      guard case let .success(balance) = result else {
        XCTFail()
        return
      }

      XCTAssert(balance > Tez.zeroBalance)
      completionExpectation.fulfill()
    }
    wait(for: [ completionExpectation ], timeout: .expectationTimeout)
  }

  public func testGetBalanceTokens() {
    let completionExpectation = XCTestExpectation(description: "Completion called")

    exchangeClient.getExchangeBalanceTokens(tokenContractAddress: .tokenContractAddress) { result in
      guard case let .success(balance) = result else {
        XCTFail()
        return
      }

      XCTAssert(balance > 0)
      completionExpectation.fulfill()
    }
    wait(for: [ completionExpectation ], timeout: .expectationTimeout)
  }

  public func testGetExchangeLiquidity() {
    let completionExpectation = XCTestExpectation(description: "Completion called")

    exchangeClient.getExchangeLiquidity { result in
      guard case let .success(liquidity) = result else {
        XCTFail()
        return
      }

      XCTAssert(liquidity > 0)
      completionExpectation.fulfill()
    }
    wait(for: [ completionExpectation ], timeout: .expectationTimeout)
  }

  public func testAddLiquidity() {
    let completionExpectation = XCTestExpectation(description: "Completion called")

    let deadline = Date().addingTimeInterval(24 * 60 * 60) // 24 hours in the future
    exchangeClient.addLiquidity(
      from: Wallet.testWallet.address,
      amount: Tez(10.0),
      signatureProvider: Wallet.testWallet,
      minLiquidity: 1,
      maxTokensDeposited: 100,
      deadline: deadline
    ) { result in
      switch result {
      case .failure(let error):
        print(error)
        XCTFail()
      case .success(let hash):
        print(hash)
        completionExpectation.fulfill()
      }
    }

    wait(for: [ completionExpectation ], timeout: .expectationTimeout)
  }

  public func testRemoveLiquidity() {
    let completionExpectation = XCTestExpectation(description: "Completion called")

    let deadline = Date().addingTimeInterval(24 * 60 * 60) // 24 hours in the future
    exchangeClient.removeLiquidity(
      from: Wallet.testWallet.address,
      destination: Wallet.testWallet.address,
      signatureProvider: Wallet.testWallet,
      liquidityBurned: 5_000_000,
      tezToWidthdraw: Tez(0.000_001),
      minTokensToWithdraw: 1,
      deadline: deadline
    ) { result in
      switch result {
      case .failure(let error):
        print(error)
        XCTFail()
      case .success(let hash):
        print(hash)
        completionExpectation.fulfill()
      }
    }

    wait(for: [ completionExpectation ], timeout: .expectationTimeout)
  }

  public func testTradeTezForToken() {
    let completionExpectation = XCTestExpectation(description: "Completion called")

    let deadline = Date().addingTimeInterval(24 * 60 * 60) // 24 hours in the future

    exchangeClient.tradeTezForToken(
      source: Wallet.testWallet.address,
      amount: Tez(5.0),
      signatureProvider: Wallet.testWallet,
      minTokensToPurchase: 1,
      deadline: deadline
    ) { result in
      switch result {
      case .failure(let error):
        print(error)
        XCTFail()
      case .success(let hash):
        print(hash)
        completionExpectation.fulfill()
      }
    }

    wait(for: [ completionExpectation ], timeout: .expectationTimeout)
  }

  func testTradeTokenForTez() {
    let completionExpectation = XCTestExpectation(description: "Completion called")

    let deadline = Date().addingTimeInterval(24 * 60 * 60) // 24 hours in the future

    exchangeClient.tradeTokenForTez(
      source: Wallet.testWallet.address,
      destination: Wallet.testWallet.address,
      signatureProvider: Wallet.testWallet,
      tokensToSell: 40,
      minTezToBuy: Tez(0.000_001),
      deadline: deadline
    ) { result in
      switch result {
      case .failure(let error):
        print(error)
        XCTFail()
      case .success(let hash):
        print(hash)
        completionExpectation.fulfill()
      }
    }

    wait(for: [ completionExpectation ], timeout: .expectationTimeout)
  }
}
