// Copyright Keefer Taylor, 2019.

import PromiseKit
@testable import TezosKit
import XCTest

extension NetworkClientTest {
  public func testCallbackOnCorrectQueueForBadURL_promises() {
    let expectation = XCTestExpectation(description: "Promise is resolved")

    // RPC endpoint will not resolve to a valid URL.
    let rpc = RPC(endpoint: "/    /\"test", responseAdapterClass: StringResponseAdapter.self)
    networkClient?.send(rpc) { _ in
      if #available(iOS 10, OSX 10.12, *) {
        dispatchPrecondition(condition: .onQueue(self.callbackQueue))
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  public func testCallbackOnCorrectQueue_promises() {
    let expectation = XCTestExpectation(description: "Promise is resolved")
    let rpc = RPC(endpoint: "/test", responseAdapterClass: StringResponseAdapter.self)
    networkClient?.send(rpc) { _ in
      if #available(iOS 10, OSX 10.12, *) {
        dispatchPrecondition(condition: .onQueue(self.callbackQueue))
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  public func testBadEndpointCompletesWithURL_promises() {
    let expectation = XCTestExpectation(description: "Promise is resolved")

    // RPC endpoint will not resolve to a valid URL.
    let rpc = RPC(endpoint: "/    /\"test", responseAdapterClass: StringResponseAdapter.self)
    networkClient?.send(rpc).done { _ in
      XCTFail()
    }.catch { error in
      XCTAssertNotNil(error)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  public func testBadHTTPResponseCompletesWithError_promises() {
    // Fake URL session has data but has an HTTP error code.
    fakeURLSession.urlResponse = HTTPURLResponse(
      url: URL(string: "http://keefertaylor.com")!,
      statusCode: 400,
      httpVersion: nil,
      headerFields: nil
    )
    fakeURLSession.data = "SomeString".data(using: .utf8)

    let expectation = XCTestExpectation(description: "Promise is resolved")
    let rpc = RPC(endpoint: "/test", responseAdapterClass: StringResponseAdapter.self)
    networkClient?.send(rpc).done { _ in
      XCTFail()
    }.catch { error in
      XCTAssertNotNil(error)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  public func testErrorCompletesWithError_promises() {
    // Valid HTTP response and data, but error is returned.
    fakeURLSession.urlResponse = HTTPURLResponse(
      url: URL(string: "http://keefertaylor.com")!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    )
    fakeURLSession.data = "Result".data(using: .utf8)
    fakeURLSession.error = TezosKitError(kind: .unknown, underlyingError: nil)

    let expectation = XCTestExpectation(description: "Promise is resolved")
    let rpc = RPC(endpoint: "/test", responseAdapterClass: StringResponseAdapter.self)
    networkClient?.send(rpc).done { _ in
      XCTFail()
    }.catch { error in
      XCTAssertNotNil(error)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  public func testNilDataCompletesWithError_promises() {
    // Valid HTTP response, but returned data is nil.
    fakeURLSession.urlResponse = HTTPURLResponse(
      url: URL(string: "http://keefertaylor.com")!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    )

    let expectation = XCTestExpectation(description: "Promise is resolved")
    let rpc = RPC(endpoint: "/test", responseAdapterClass: StringResponseAdapter.self)
    networkClient?.send(rpc).done { _ in
      XCTFail()
    }.catch { error in
      XCTAssertNotNil(error)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  public func testInocrrectDataCompletesWithError_promises() {
    // Response is a string but RPC attempts to decode to an int.
    fakeURLSession.urlResponse = HTTPURLResponse(
      url: URL(string: "http://keefertaylor.com")!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    )

    let expectation = XCTestExpectation(description: "Promise is resolved")
    let rpc = RPC(endpoint: "/test", responseAdapterClass: IntegerResponseAdapter.self)
    networkClient?.send(rpc).done { _ in
      XCTFail()
    } .catch { error in
      XCTAssertNotNil(error)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }

  public func testRequestCompletesWithResultAndNoError_promises() {
    // A valid response with not HTTP error.
    let expectedString = "Expected!"
    fakeURLSession.urlResponse = HTTPURLResponse(
      url: URL(string: "http://keefertaylor.com")!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    )
    fakeURLSession.data = expectedString.data(using: .utf8)

    let expectation = XCTestExpectation(description: "Promise is resolved")
    let rpc = RPC(endpoint: "/test", responseAdapterClass: StringResponseAdapter.self)
    networkClient?.send(rpc).done { result in
      XCTAssertNotNil(result)
      XCTAssertEqual(result, expectedString)
      expectation.fulfill()
    }.catch { _ in
      XCTFail()
    }

    wait(for: [expectation], timeout: .expectationTimeout)
  }
}
