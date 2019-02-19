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
  let responseHandler = RPCResponseHandler()

  /// Test values.
  let testURL = URL(string: "http://github.com/keefertaylor/TezosKit")!

  let testErrorString = "flagrant error!"
  var testErrorStringData: Data? // Above string as raw bytes.

  let testParsedString = "success!"
  var testParsedStringData: Data? // Above string as raw bytes.

  public override func setUp() {
    super.setUp()

    testErrorStringData = testErrorString.data(using: .utf8)!
    testParsedStringData = testParsedString.data(using: .utf8)!
  }

  public func testHandleResponseWithHTTP400() {
    let response = httpResponse(with: 400)
    let (result, error) = responseHandler.handleResponse(
      response: response,
      data: testErrorStringData,
      error: TestError.testError,
      responseAdapterClass: StringResponseAdapter.self
    )

    XCTAssertNil(result)
    XCTAssertNotNil(error)

    guard let tezosKitError = error as? TezosClientError else {
      XCTFail()
      return
    }

    XCTAssertEqual(tezosKitError.kind, .unexpectedRequestFormat)
    XCTAssertEqual(tezosKitError.underlyingError, testErrorString)
  }

  public func testHandleResponseWithHTTP500() {
    let response = httpResponse(with: 500)
    let (result, error) = responseHandler.handleResponse(
      response: response,
      data: testErrorStringData,
      error: TestError.testError,
      responseAdapterClass: StringResponseAdapter.self
    )

    XCTAssertNil(result)
    XCTAssertNotNil(error)

    guard let tezosKitError = error as? TezosClientError else {
      XCTFail()
      return
    }

    XCTAssertEqual(tezosKitError.kind, .unexpectedResponse)
    XCTAssertEqual(tezosKitError.underlyingError, testErrorString)
  }

  public func testHandleResponseWithHTTPInvalid() {
    let response = httpResponse(with: 9_000)
    let (result, error) = responseHandler.handleResponse(
      response: response,
      data: testErrorStringData,
      error: TestError.testError,
      responseAdapterClass: StringResponseAdapter.self
    )

    XCTAssertNil(result)
    XCTAssertNotNil(error)

    guard let tezosKitError = error as? TezosClientError else {
      XCTFail()
      return
    }

    XCTAssertEqual(tezosKitError.kind, .unknown)
    XCTAssertEqual(tezosKitError.underlyingError, testErrorString)
  }

  public func testHandleResponseWithHTTP200AndError() {
    let response = httpResponse(with: 200)
    let testError = TestError.testError
    let (result, error) = responseHandler.handleResponse(
      response: response,
      data: testParsedStringData,
      error: testError,
      responseAdapterClass: StringResponseAdapter.self
    )

    XCTAssertNotNil(error)
    XCTAssertNil(result)

    guard let tezosKitError = error as? TezosClientError else {
      XCTFail()
      return
    }

    XCTAssertEqual(tezosKitError.kind, .rpcError)
    XCTAssertEqual(tezosKitError.underlyingError, testError.localizedDescription)
  }

  public func testHandleResponseWithHTTP200AndNilErrorAndValidData() {
    let response = httpResponse(with: 200)
    let (result, error) = responseHandler.handleResponse(
      response: response,
      data: testParsedStringData,
      error: nil,
      responseAdapterClass: StringResponseAdapter.self
    )

    XCTAssertNil(error)
    XCTAssertNotNil(result)
    XCTAssertEqual(result, testParsedString)
  }

  public func testHandleResponseWithHTTP200AndNilErrorAndNoData() {
    let response = httpResponse(with: 200)
    let (result, error) = responseHandler.handleResponse(
      response: response,
      data: nil,
      error: nil,
      responseAdapterClass: StringResponseAdapter.self
    )

    XCTAssertNotNil(error)
    XCTAssertNil(result)

    guard let tezosKitError = error as? TezosClientError else {
      XCTFail()
      return
    }

    XCTAssertEqual(tezosKitError.kind, .unexpectedResponse)
    XCTAssertEqual(tezosKitError.underlyingError, nil)
  }

  public func testHandleResponseWithHTTP200AndNilErrorAndBadData() {
    let response = httpResponse(with: 200)
    let (result, error) = responseHandler.handleResponse(
      response: response,
      data: testParsedStringData,
      error: nil,
      responseAdapterClass: PeriodKindResponseAdapter.self
    )

    XCTAssertNotNil(error)
    XCTAssertNil(result)

    guard let tezosKitError = error as? TezosClientError else {
      XCTFail()
      return
    }

    XCTAssertEqual(tezosKitError.kind, .unexpectedResponse)
    XCTAssertEqual(tezosKitError.underlyingError, nil)
  }

  private func httpResponse(with code: Int) -> HTTPURLResponse {
    return HTTPURLResponse(url: testURL, statusCode: code, httpVersion: nil, headerFields: nil)!
  }
}
