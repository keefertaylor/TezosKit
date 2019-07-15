// Copyright Keefer Taylor, 2019

import TezosKit
import XCTest

final class InjectionServiceTest: XCTestCase {
  func testInjectionService() {
    let networkClient = FakeNetworkClient.tezosNodeNetworkClient
    let injectionService = InjectionService(networkClient: networkClient)
    let hex = String.testSignedBytesForInjection

    let expectation = XCTestExpectation(description: "injection completion called")
    injectionService.inject(payload: hex) { result in
      switch result {
      case .success:
        expectation.fulfill()
      case .failure:
        XCTFail()
      }
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  // swiftlint:disable force_cast

  func testInjectionServiceBadResponse() {
    let networkClient = FakeNetworkClient.tezosNodeNetworkClient.copy() as! FakeNetworkClient
    networkClient.endpointToResponseMap["/injection/operation"] = nil
    let injectionService = InjectionService(networkClient: networkClient)
    let hex = String.testSignedBytesForInjection

    let expectation = XCTestExpectation(description: "injection completion called")
    injectionService.inject(payload: hex) { result in
      switch result {
      case .success:
        XCTFail()
      case .failure:
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  // swiftlint:enable force_cast

}
