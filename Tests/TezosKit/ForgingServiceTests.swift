// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

class ForgingServiceTests: XCTestCase {
  func testForgingServiceWithRemotePolicy() {
    let forgingServiceDelegate = FakeForgingServiceDelegate() {
      return .success(.testForgeResult)
    }

    let forgingService = ForgingService(forgingPolicy: .remote)
    forgingService.delegate = forgingServiceDelegate

    let forgeCompletionExpectation = XCTestExpectation(description: "Forge completion called.")

    forgingService.forge(operationPayload: .testOperationPayload, operationMetadata: .testOperationMetadata) { result in
      switch result {
      case .success(let forgingServiceForgeResult):
        XCTAssertEqual(forgingServiceForgeResult, .testForgeResult)
      case .failure:
        XCTFail()
      }
      forgeCompletionExpectation.fulfill()
    }

    wait(for: [forgeCompletionExpectation], timeout: .expectationTimeout)
  }

  func testForgingServiceWithLocalPolicy() {
    let forgingService = ForgingService(forgingPolicy: .local)

    let forgeCompletionExpectation = XCTestExpectation(description: "Forge completion called.")
    forgingService.forge(operationPayload: .testOperationPayload, operationMetadata: .testOperationMetadata) { result in
      switch result {
      case .success:
        XCTFail()
      case .failure(let error):
        XCTAssertEqual(error.kind, .localForgingNotSupportedForOperation)
      }
      forgeCompletionExpectation.fulfill()
    }

    wait(for: [forgeCompletionExpectation], timeout: .expectationTimeout)
  }

  func testForgingServiceWithLocalWithRemoteFallbackPolicyAndUnforgeableOperation() {
    let forgingServiceDelegate = FakeForgingServiceDelegate() {
      return .success(.testForgeResult)
    }

    let forgingService = ForgingService(forgingPolicy: .localWithRemoteFallBack)
    forgingService.delegate = forgingServiceDelegate

    let forgeCompletionExpectation = XCTestExpectation(description: "Forge completion called.")

    forgingService.forge(operationPayload: .testOperationPayload, operationMetadata: .testOperationMetadata) { result in
      switch result {
      case .success(let forgingServiceForgeResult):
        XCTAssertEqual(forgingServiceForgeResult, .testForgeResult)
      case .failure:
        XCTFail()
      }
      forgeCompletionExpectation.fulfill()
    }

    wait(for: [forgeCompletionExpectation], timeout: .expectationTimeout)
  }
}
