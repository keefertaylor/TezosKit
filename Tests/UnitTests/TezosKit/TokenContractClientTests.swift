// Copyright Keefer Taylor, 2019.

@testable import TezosKit
import XCTest

final class TokenContractClientTests: XCTestCase {
  private var tokenContractClient: TokenContractClient?

  override func setUp() {
    super.setUp()

    let contract = Address.testTokenContractAddress
    let networkClient = FakeNetworkClient.tezosNodeNetworkClient

    let tezosNodeClient = TezosNodeClient(networkClient: networkClient)
    tokenContractClient = TokenContractClient(
      tokenContractAddress: contract,
      tezosNodeClient: tezosNodeClient
    )
  }

  func testTransferTokens() {
    let expectation = XCTestExpectation(description: "completion called")

    tokenContractClient?.transferTokens(
      from: Address.testAddress,
      to: Address.testDestinationAddress,
      numTokens: 1,
      signatureProvider: FakeSignatureProvider.testSignatureProvider
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

  func testGetBalance() {
    let expectation = XCTestExpectation(description: "completion called")

    tokenContractClient?.getTokenBalance(address: Address.testAddress) { result in
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
