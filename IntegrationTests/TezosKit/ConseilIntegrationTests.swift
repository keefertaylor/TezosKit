// Copyright Keefer Taylor, 2019

import Foundation

/// Integration tests to run against a live Conseil server.
///
/// To get started using Conseil, look at:
/// https://github.com/Cryptonomic/Conseil/blob/master/doc/use-conseil.md
///
/// These tests are not hermetic and may fail for a number or reasons, such as:
/// - Adverse network conditions.
/// - Changes in Conseil
///
/// *** Configuration must be done before theses tests can be run. Please configure: ***
/// - Conseil URL
/// - Conseil API Key
let apiKey = "change me"
let remoteNodeURL = URL(string: "https://put-your-conseil-url-here")!

class ConseilIntegrationTests: XCTestCase {
  public lazy var conseilClient: ConseilClient = {
    return ConseilClient()
  }

  public func testConseilSent() {
    let expectation = XCTestExpectation(description: "completion called")
    conseilClient.transactionsSent(from: Wallet.testWallet.address) { result in
      switch result {
      case .success:
        expectation.fulfill()
      case .failure:
        XCTFail()
      }
    }
    wait(for: [expectation], timeout: .expectationTimeout)
  }

  public func testConseilReceived() {
    let expectation = XCTestExpectation(description: "completion called")
    conseilClient.transactionsReceived(from: Wallet.testWallet.address) { result in
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
