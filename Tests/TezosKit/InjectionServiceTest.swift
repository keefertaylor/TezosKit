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
}
