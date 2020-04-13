// Copyright Keefer Taylor, 2019

@testable import TezosKit
import XCTest

/// A fake error used in tests.
private enum TestError: Error {
  case testError
}

extension TestError: LocalizedError {
  public var errorDescription: String? {
    return "Oh no!"
  }
}

class RPCResponseHandlerTest: XCTestCase {
  /// Response handler to test.
  static let responseHandler = RPCResponseHandler()

  /// Test values.
  static let testURL = URL(string: "http://github.com/keefertaylor/TezosKit")!

  static let testErrorString = "flagrant error!"
  var testErrorStringData: Data? // Above string as raw bytes.

  static let testParsedString = "success!"
  var testParsedStringData: Data? // Above string as raw bytes.

  public override func setUp() {
    super.setUp()

    testErrorStringData = RPCResponseHandlerTest.testErrorString.data(using: .utf8)!
    testParsedStringData = RPCResponseHandlerTest.testParsedString.data(using: .utf8)!
  }

  public func testHandleResponseWithHTTP400() {
    let response = httpResponse(with: 400)
    let result = RPCResponseHandlerTest.responseHandler.handleResponse(
      response: response,
      data: testErrorStringData,
      error: TestError.testError,
      responseAdapterClass: StringResponseAdapter.self
    )

    // TODO(keefertaylor): Assert underlying error got set correctly.
    switch result {
    case .failure(let tezosKitError):
      switch tezosKitError {
      case .unexpectedRequestFormat:
        break
      default:
        XCTFail("Wrong error type reported")
      }
    case .success:
      XCTFail()
    }
  }

  public func testHandleResponseWithHTTP500() {
    let response = httpResponse(with: 500)
    let result = RPCResponseHandlerTest.responseHandler.handleResponse(
      response: response,
      data: testErrorStringData,
      error: TestError.testError,
      responseAdapterClass: StringResponseAdapter.self
    )

    switch result {
    case .failure(let tezosKitError):
      XCTAssertEqual(tezosKitError, .unexpectedResponse(description: RPCResponseHandlerTest.testErrorString))
    case .success:
      XCTFail()
    }
  }

  public func testHandleResponseWithHTTPInvalid() {
    let response = httpResponse(with: 9_000)
    let result = RPCResponseHandlerTest.responseHandler.handleResponse(
      response: response,
      data: testErrorStringData,
      error: TestError.testError,
      responseAdapterClass: StringResponseAdapter.self
    )

    // TODO(keefertaylor): Check for RPCResponseHandlerTest.testErrorString?
    switch result {
    case .failure(let tezosKitError):
      XCTAssertEqual(tezosKitError, .unknown(description: RPCResponseHandlerTest.testErrorString))
    case .success:
      XCTFail()
    }
  }

  public func testHandleResponseWithHTTP200AndError() {
    let response = httpResponse(with: 200)
    let testError = TestError.testError
    let result = RPCResponseHandlerTest.responseHandler.handleResponse(
      response: response,
      data: testParsedStringData,
      error: testError,
      responseAdapterClass: StringResponseAdapter.self
    )

    switch result {
    case .failure(let tezosKitError):
      switch tezosKitError {
      case .rpcError(let description):
        XCTAssertEqual(description, testError.localizedDescription)
      default:
        XCTFail("Wrong error type reported.")
      }
    case .success:
      XCTFail()
    }
  }

  public func testHandleResponseWithHTTP200AndNilErrorAndValidData() {
    let response = httpResponse(with: 200)
    let result = RPCResponseHandlerTest.responseHandler.handleResponse(
      response: response,
      data: testParsedStringData,
      error: nil,
      responseAdapterClass: StringResponseAdapter.self
    )

    switch result {
    case .failure:
      XCTFail()
    case .success(let data):
      XCTAssertEqual(data, RPCResponseHandlerTest.testParsedString)
    }
  }

  public func testHandleResponseWithHTTP200AndNilErrorAndNoData() {
    let response = httpResponse(with: 200)
    let result = RPCResponseHandlerTest.responseHandler.handleResponse(
      response: response,
      data: nil,
      error: nil,
      responseAdapterClass: StringResponseAdapter.self
    )

    switch result {
    case .failure(let tezosKitError):
      XCTAssertEqual(tezosKitError, .unexpectedResponse(description: "No data in response"))
    case .success:
      XCTFail()
    }
  }

  public func testHandleResponseWithHTTP200AndNilErrorAndBadData() {
    let response = httpResponse(with: 200)
    let result = RPCResponseHandlerTest.responseHandler.handleResponse(
      response: response,
      data: testParsedStringData,
      error: nil,
      responseAdapterClass: PeriodKindResponseAdapter.self
    )

    switch result {
    case .failure(let tezosKitError):
      XCTAssertEqual(tezosKitError, .unexpectedResponse(description: "No data in response"))
    case .success:
      XCTFail()
    }
  }

// MARK: - Helpers

  private func httpResponse(with code: Int) -> HTTPURLResponse {
    return HTTPURLResponse(url: RPCResponseHandlerTest.testURL, statusCode: code, httpVersion: nil, headerFields: nil)!
  }
}
