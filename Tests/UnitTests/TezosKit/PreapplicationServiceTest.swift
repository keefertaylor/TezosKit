// Copyright Keefer Taylor, 2019.

@testable import TezosKit
import XCTest

final class PreapplicationServiceTest: XCTestCase {
  private static let preapplyEndpoint = "/chains/main/blocks/" + .testBranch + "/helpers/preapply/operations"

  // swiftlint:disable line_length
  private static let invalidPreapplicationResponse =
    "[{\"contents\":[{\"kind\":\"transaction\",\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"fee\":\"1272\",\"counter\":\"30802\",\"gas_limit\":\"10100\",\"storage_limit\":\"257\",\"amount\":\"10000000000000\",\"destination\":\"tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5\",\"metadata\":{\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"change\":\"-1272\"},{\"kind\":\"freezer\",\"category\":\"fees\",\"delegate\":\"tz1Ke2h7sDdakHJQh8WX4Z372du1KChsksyU\",\"level\":125,\"change\":\"1272\"}],\"operation_result\":{\"status\":\"failed\",\"errors\":[{\"kind\":\"temporary\",\"id\":\"proto.003-PsddFKi3.contract.balance_too_low\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"balance\":\"98751713\",\"amount\":\"10000000000000\"}]}}}],\"signature\":\"edsigu16pv1NUsXuJkwWDAqvFDbhcsRAHbdxbYJcN7AShN4yDspRmsP5kgbzs2osTHGGDkyED3vjQFcbskv3BVESJ7tpchmbbop\"}]"
  // swiftlint:enable line_length

  func testPreapplicationValidOperation() {
    let networkClient = FakeNetworkClient.tezosNodeNetworkClient
    let preapplicationService = PreapplicationService(networkClient: networkClient)

    let preapplicationCompletionExpectation = XCTestExpectation(description: "Preapplication completion called.")
    preapplicationService.preapply(
      signedProtocolOperationPayload: .testSignedProtocolOperationPayload,
      signedBytesForInjection: .testSignedBytesForInjection,
      operationMetadata: .testOperationMetadata
    ) { result in
      guard result == nil else {
        XCTFail()
        return
      }
      preapplicationCompletionExpectation.fulfill()
    }

    wait(for: [preapplicationCompletionExpectation], timeout: .expectationTimeout)
  }

  // swiftlint:disable force_cast

  func testPreapplicationInvalidOperation() {
    let networkClient = FakeNetworkClient.tezosNodeNetworkClient.copy() as! FakeNetworkClient
    networkClient.endpointToResponseMap[PreapplicationServiceTest.preapplyEndpoint] =
      PreapplicationServiceTest.invalidPreapplicationResponse
    let preapplicationService = PreapplicationService(networkClient: networkClient)

    let preapplicationCompletionExpectation = XCTestExpectation(description: "Preapplication completion called.")
    preapplicationService.preapply(
      signedProtocolOperationPayload: .testSignedProtocolOperationPayload,
      signedBytesForInjection: .testSignedBytesForInjection,
      operationMetadata: .testOperationMetadata
    ) { result in
      guard let result = result else {
        XCTFail()
        return
      }
      XCTAssertEqual(result.kind, .preapplicationError)
      preapplicationCompletionExpectation.fulfill()
    }

    wait(for: [preapplicationCompletionExpectation], timeout: .expectationTimeout)
  }

  func testPreapplicationInvalidResponse() {
    let networkClient = FakeNetworkClient.tezosNodeNetworkClient.copy() as! FakeNetworkClient
    networkClient.endpointToResponseMap[PreapplicationServiceTest.preapplyEndpoint] = "nonsense"
    let preapplicationService = PreapplicationService(networkClient: networkClient)

    let preapplicationCompletionExpectation = XCTestExpectation(description: "Preapplication completion called.")
    preapplicationService.preapply(
      signedProtocolOperationPayload: .testSignedProtocolOperationPayload,
      signedBytesForInjection: .testSignedBytesForInjection,
      operationMetadata: .testOperationMetadata
    ) { result in
      guard let result = result else {
        XCTFail()
        return
      }
      XCTAssertEqual(result.kind, .unexpectedResponse)
      preapplicationCompletionExpectation.fulfill()
    }

    wait(for: [preapplicationCompletionExpectation], timeout: .expectationTimeout)
  }

  // swiftlint:enable force_cast

  func testPreapplyErrorFromResponseValidOperation() {
    let validPreapplyResponse =
      FakeNetworkClient.tezosNodeNetworkClient.endpointToResponseMap[PreapplicationServiceTest.preapplyEndpoint]!
    let json = JSONArrayResponseAdapter.parse(input: validPreapplyResponse.data(using: .utf8)!)!
    XCTAssertNil(PreapplicationService.preapplicationError(from: json))
  }

  func testPreapplyErrorFromResponseInvalidOperation() {
    let json = JSONArrayResponseAdapter.parse(
      input: PreapplicationServiceTest.invalidPreapplicationResponse.data(using: .utf8)!
    )!
    let error = PreapplicationService.preapplicationError(from: json)!
    XCTAssertEqual(error.kind, .preapplicationError)
    XCTAssert(error.underlyingError!.contains("contract.balance_too_low"))
  }
}
