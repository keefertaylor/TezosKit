// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

final class OperationMetadataProviderTests: XCTestCase {
  func testOperationMetadataWithValidResponsesSync() {
    let operationMetadataProvider = OperationMetadataProvider(networkClient: FakeNetworkClient.tezosNodeNetworkClient)

    let result = operationMetadataProvider.metadataSync(for: .testAddress)

    guard case let .success(metadata) = result else {
      XCTFail()
      return
    }

    XCTAssertEqual(metadata.addressCounter, .testAddressCounter)
    XCTAssertEqual(metadata.branch, .testBranch)
    XCTAssertEqual(metadata.key, .testPublicKey)
    XCTAssertEqual(metadata.protocol, .testProtocol)
  }

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

  // swiftlint:disable force_cast

  func testOperationMetadataWithInvalidCounter() {
    let networkClient = FakeNetworkClient.tezosNodeNetworkClient.copy() as! FakeNetworkClient
    let endpoint = "/chains/main/blocks/head/context/contracts/" + .testAddress + "/counter"
    networkClient.endpointToResponseMap[endpoint] = "nonsense"
    let operationMetadataProvider = OperationMetadataProvider(networkClient: networkClient)

    let completionCalledExpection = XCTestExpectation()
    operationMetadataProvider.metadata(for: .testAddress) { result in
      switch result {
      case .success:
        XCTFail()
      case .failure:
        completionCalledExpection.fulfill()
      }
    }

    wait(for: [completionCalledExpection], timeout: .expectationTimeout)
  }

  func testOperationMetadataWithMissingManagerKey() {
    let networkClient = FakeNetworkClient.tezosNodeNetworkClient.copy() as! FakeNetworkClient
    let endpoint = "/chains/main/blocks/head/context/contracts/" + .testAddress + "/manager_key"
    networkClient.endpointToResponseMap[endpoint] = "null"
    let operationMetadataProvider = OperationMetadataProvider(networkClient: networkClient)

    let completionCalledExpection = XCTestExpectation()
    operationMetadataProvider.metadata(for: .testAddress) { result in
      switch result {
      case .success(let metadata):
        XCTAssertEqual(metadata.key, nil)
      case .failure:
        XCTFail()
      }
      completionCalledExpection.fulfill()
    }

    wait(for: [completionCalledExpection], timeout: .expectationTimeout)
  }

  func testOperationMetadataWithInvalidHead() {
    let networkClient = FakeNetworkClient.tezosNodeNetworkClient.copy() as! FakeNetworkClient
    let endpoint = "/chains/main/blocks/head"
    networkClient.endpointToResponseMap[endpoint] = "nonsense"
    let operationMetadataProvider = OperationMetadataProvider(networkClient: networkClient)

    let completionCalledExpection = XCTestExpectation()
    operationMetadataProvider.metadata(for: .testAddress) { result in
      switch result {
      case .success:
        XCTFail()
      case .failure:
        completionCalledExpection.fulfill()
      }
    }

    wait(for: [completionCalledExpection], timeout: .expectationTimeout)
  }

  // swiftlint:enable force_cast
}
