// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

class ForgingServiceTests: XCTestCase {
  func testForgingServiceCallsRemoteForge() {
    let testForgeResult = "test_forge_result"
    let forgingServiceDelegate = FakeForgingServiceDelegate() {
      return .success(testForgeResult)
    }

    let forgingService = ForgingService(forgingPolicy: .remote)
    forgingService.delegate = forgingServiceDelegate

    let forgeCompletionExpectation = XCTestExpectation(description: "Forge completion called.")

    forgingService.forge(operationPayload: .testOperationPayload, operationMetadata: .testOperationMetadata) { result in
      switch result {
      case .success(let forgingServiceForgeResult):
        XCTAssertEqual(forgingServiceForgeResult, testForgeResult)
      case .failure:
        XCTFail()
      }
      forgeCompletionExpectation.fulfill()
    }

    wait(for: [forgeCompletionExpectation], timeout: .expectationTimeout)
  }
}
