// Copyright Keefer Taylor, 2019.

@testable import TezosKit
import XCTest

/// A fake URLSession that will return data tasks which will call completion handlers with the given parameters.
public class FakeURLSession: URLSession {
  public var urlResponse: URLResponse?
  public var data: Data?
  public var error: Error?

  public override func dataTask(
    with request: URLRequest,
    completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
  ) -> URLSessionDataTask {
    return FakeURLSessionDataTask(
      urlResponse: urlResponse,
      data: data,
      error: error,
      completionHandler: completionHandler
    )
  }
}

/// A fake data task that will immediately call completion.
public class FakeURLSessionDataTask: URLSessionDataTask {
  private let urlResponse: URLResponse?
  private let data: Data?
  private let fakedError: Error?
  private let completionHandler: (Data?, URLResponse?, Error?) -> Void

  public init(
    urlResponse: URLResponse?,
    data: Data?,
    error: Error?,
    completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) {
    self.urlResponse = urlResponse
    self.data = data
    self.fakedError = error
    self.completionHandler = completionHandler
  }

  public override func resume() {
    completionHandler(data, urlResponse, fakedError)
  }
}

class AbstractClientTest: XCTestCase {
  public var abstractClient: AbstractClient?

  public let fakeURLSession = FakeURLSession()
  public let callbackQueue: DispatchQueue = DispatchQueue(label: "callbackQueue")

  public override func setUp() {
    super.setUp()

    abstractClient = AbstractClient(
      remoteNodeURL: URL(string: "http://github.com/keefertaylor/TezosKit")!,
      urlSession: fakeURLSession,
      callbackQueue: callbackQueue,
      responseHandler: RPCResponseHandler()
    )
  }

  public func testCallbackOnCorrectQueueForBadURL() {
    let expectation = XCTestExpectation(description: "Completion is Called")

    // RPC endpoint will not resolve to a valid URL.
    let rpc = RPC(endpoint: "/    /\"test", responseAdapterClass: StringResponseAdapter.self)
    abstractClient?.send(rpc: rpc) { (_, _) in
      if #available(iOS 10, OSX 10.12, *) {
        dispatchPrecondition(condition: .onQueue(self.callbackQueue))
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10)
  }

  public func testCallbackOnCorrectQueue() {
    let expectation = XCTestExpectation(description: "Completion is Called")
    let rpc = RPC(endpoint: "/test", responseAdapterClass: StringResponseAdapter.self)
    abstractClient?.send(rpc: rpc) { (_, _) in
      if #available(iOS 10, OSX 10.12, *) {
        dispatchPrecondition(condition: .onQueue(self.callbackQueue))
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10)
  }

  public func testBadEndpoingCompletesWithURL() {
    let expectation = XCTestExpectation(description: "Completion is Called")

    // RPC endpoint will not resolve to a valid URL.
    let rpc = RPC(endpoint: "/    /\"test", responseAdapterClass: StringResponseAdapter.self)
    abstractClient?.send(rpc: rpc) { (result, error) in
      XCTAssertNil(result)
      XCTAssertNotNil(error)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10)
  }

  public func testBadHTTPResponseCompletesWithError() {
    // Fake URL session has data but has an HTTP error code.
    fakeURLSession.urlResponse = HTTPURLResponse(
      url: URL(string: "http://keefertaylor.com")!,
      statusCode: 400,
      httpVersion: nil,
      headerFields: nil
    )
    fakeURLSession.data = "SomeString".data(using: .utf8)

    let expectation = XCTestExpectation(description: "Completion is Called")
    let rpc = RPC(endpoint: "/test", responseAdapterClass: StringResponseAdapter.self)
    abstractClient?.send(rpc: rpc) { (result, error) in
      XCTAssertNil(result)
      XCTAssertNotNil(error)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10)
  }

  public func testErrorCompletesWithError() {
    // Valid HTTP response and data, but error is returned.
    fakeURLSession.urlResponse = HTTPURLResponse(
      url: URL(string: "http://keefertaylor.com")!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    )
    fakeURLSession.data = "Result".data(using: .utf8)
    fakeURLSession.error = TezosKitError(kind: .unknown, underlyingError: nil)

    let expectation = XCTestExpectation(description: "Completion is Called")
    let rpc = RPC(endpoint: "/test", responseAdapterClass: StringResponseAdapter.self)
    abstractClient?.send(rpc: rpc) { (result, error) in
      XCTAssertNil(result)
      XCTAssertNotNil(error)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10)
  }

  public func testNilDataCompletesWithError() {
    // Valid HTTP response, but returned data is nil.
    fakeURLSession.urlResponse = HTTPURLResponse(
      url: URL(string: "http://keefertaylor.com")!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    )

    let expectation = XCTestExpectation(description: "Completion is Called")
    let rpc = RPC(endpoint: "/test", responseAdapterClass: StringResponseAdapter.self)
    abstractClient?.send(rpc: rpc) { (result, error) in
      XCTAssertNil(result)
      XCTAssertNotNil(error)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10)
  }

  public func testInocrrectDataCompletesWithError() {
    // Response is a string but RPC attempts to decode to an int.
    fakeURLSession.urlResponse = HTTPURLResponse(
      url: URL(string: "http://keefertaylor.com")!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    )

    let expectation = XCTestExpectation(description: "Completion is Called")
    let rpc = RPC(endpoint: "/test", responseAdapterClass: IntegerResponseAdapter.self)
    abstractClient?.send(rpc: rpc) { (result, error) in
      XCTAssertNil(result)
      XCTAssertNotNil(error)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10)
  }

  public func testRequestCompletesWithResultAndNoError() {
    // A valid response with not HTTP error.
    let expectedString = "Expected!"
    fakeURLSession.urlResponse = HTTPURLResponse(
      url: URL(string: "http://keefertaylor.com")!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    )
    fakeURLSession.data = expectedString.data(using: .utf8)

    let expectation = XCTestExpectation(description: "Completion is Called")
    let rpc = RPC(endpoint: "/test", responseAdapterClass: StringResponseAdapter.self)
    abstractClient?.send(rpc: rpc) { (result, error) in
      XCTAssertNotNil(result)
      XCTAssertEqual(result, expectedString)
      XCTAssertNil(error)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10)
  }
}
