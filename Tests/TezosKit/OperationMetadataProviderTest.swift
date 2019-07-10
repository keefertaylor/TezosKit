// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

final class OperationMetadataProviderTests: XCTestCase {
  func testOperationMetadataWithValidResponses() {
    let operationMetadataProvider = OperationMetadataProvider(networkClient: FakeNetworkClient.tezosNodeNetworkClient)

    let completionCalledExpection = XCTestExpectation()

    operationMetadataProvider.metadata(for: .testAddress) { result in
      switch result {
      case .success(let metadata):
        XCTAssertEqual(metadata.addressCounter, .testAddressCounter)
        XCTAssertEqual(metadata.branch, .testBranch)
        XCTAssertEqual(metadata.key, .testPublicKey)
        XCTAssertEqual(metadata.protocol, .testProtocol)
      case .failure:
        XCTFail()
      }
      completionCalledExpection.fulfill()
    }

    wait(for: [completionCalledExpection], timeout: .expectationTimeout)
  }
}
