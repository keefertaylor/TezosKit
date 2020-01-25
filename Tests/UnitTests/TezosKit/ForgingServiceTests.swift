// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

class ForgingServiceTests: XCTestCase {
  func testForgingServiceWithRemotePolicySync() {
    let forgingService = ForgingService(forgingPolicy: .remote, networkClient: FakeNetworkClient.tezosNodeNetworkClient)

    let result = forgingService.forgeSync(
      operationPayload: .testOperationPayload,
      operationMetadata: .testOperationMetadata
    )

    guard case let .success(forgingServiceForgeResult) = result else {
      XCTFail()
      return
    }

    XCTAssertEqual(forgingServiceForgeResult, .testForgeResult)
  }

  func testForgingServiceWithRemotePolicy() {
    let forgingService = ForgingService(forgingPolicy: .remote, networkClient: FakeNetworkClient.tezosNodeNetworkClient)

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
    let forgingService = ForgingService(forgingPolicy: .local, networkClient: FakeNetworkClient.tezosNodeNetworkClient)

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
    let forgingService = ForgingService(
      forgingPolicy: .localWithRemoteFallBack,
      networkClient: FakeNetworkClient.tezosNodeNetworkClient
    )

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
