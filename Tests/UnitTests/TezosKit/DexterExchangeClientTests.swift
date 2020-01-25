// Copyright Keefer Taylor, 2019.

@testable import TezosKit
import XCTest

final class DexterExchangeClientTests: XCTestCase {
  private var exchangeClient: DexterExchangeClient?

  override func setUp() {
    super.setUp()

    let contract = Address.testExchangeContractAddress
    let networkClient = FakeNetworkClient.tezosNodeNetworkClient

    let tezosNodeClient = TezosNodeClient(networkClient: networkClient)
    exchangeClient = DexterExchangeClient(
      exchangeContractAddress: contract,
      tezosNodeClient: tezosNodeClient
    )
  }

  func testGetExchangeLiquidity() {
    let expectation = XCTestExpectation(description: "completion called")

    exchangeClient?.getExchangeLiquidity { result in
      switch result {
      case .success:
        expectation.fulfill()
      case .failure:
        XCTFail()
      }
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  func testGetExchangeBalanceTokens() {
    let expectation = XCTestExpectation(description: "completion called")

    exchangeClient?.getExchangeBalanceTokens(tokenContractAddress: .testTokenContractAddress) { result in
      switch result {
      case .success:
        expectation.fulfill()
      case .failure:
        XCTFail()
      }
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  func testGetExchangeBalanceTez() {
    let expectation = XCTestExpectation(description: "completion called")

    exchangeClient?.getExchangeBalanceTez { result in
      switch result {
      case .success:
        expectation.fulfill()
      case .failure:
        XCTFail()
      }
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  func testAddLiquidity() {
    let expectation = XCTestExpectation(description: "completion called")

    exchangeClient?.addLiquidity(
      from: Address.testAddress,
      amount: Tez(1.0),
      signatureProvider: FakeSignatureProvider.testSignatureProvider,
      minLiquidity: 1,
      maxTokensDeposited: 1,
      deadline: Date()
    ) { result in
      switch result {
      case .success:
        expectation.fulfill()
      case .failure:
        XCTFail()
      }
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  func testWithdrawLiquidity() {
    let expectation = XCTestExpectation(description: "completion called")

    exchangeClient?.removeLiquidity(
      from: Address.testAddress,
      destination: Address.testAddress,
      signatureProvider: FakeSignatureProvider.testSignatureProvider,
      liquidityBurned: 1,
      tezToWidthdraw: Tez(1.0),
      minTokensToWithdraw: 1,
      deadline: Date()
    ) { result in
      switch result {
      case .success:
        expectation.fulfill()
      case .failure:
        XCTFail()
      }
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  func testTradeTezToTokens() {
    let expectation = XCTestExpectation(description: "completion called")

    exchangeClient?.tradeTezForToken(
      source: .testAddress,
      amount: Tez(1.0),
      signatureProvider: FakeSignatureProvider.testSignatureProvider,
      minTokensToPurchase: 1,
      deadline: Date()
    ) { result in
      switch result {
      case .success:
        expectation.fulfill()
      case .failure:
        XCTFail()
      }
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  func testTradeTokensForTez() {
    let expectation = XCTestExpectation(description: "completion called")

    exchangeClient?.tradeTokenForTez(
      source: .testAddress,
      destination: .testAddress,
      signatureProvider: FakeSignatureProvider.testSignatureProvider,
      tokensToSell: 1,
      minTezToBuy: Tez(1.0),
      deadline: Date()
    ) { result in
      switch result {
      case .success:
        expectation.fulfill()
      case .failure:
        XCTFail()
      }
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }
}
