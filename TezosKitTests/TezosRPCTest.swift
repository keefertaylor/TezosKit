// Copyright Keefer Taylor, 2018

@testable import TezosKit
import XCTest

class TezosRPCTest: XCTestCase {
  public func testIsPOSTRequest() {
    let getRPC = TezosRPC(endpoint: "a",
                          responseAdapterClass: StringResponseAdapter.self) { _, _ in }
    XCTAssertFalse(getRPC.isPOSTRequest)

    let postRPC = TezosRPC(endpoint: "a",
                           responseAdapterClass: StringResponseAdapter.self, payload: "abc") { _, _ in }
    XCTAssertTrue(postRPC.isPOSTRequest)
  }

  public func testValidDataPassedToCompletionOnHandlingValidData() {
    let completionBlockCalledExpectation = XCTestExpectation(description: "Completion called")
    let rpc = TezosRPC(endpoint: "abc", responseAdapterClass: StringResponseAdapter.self) { data, error in
      XCTAssertNotNil(data)
      XCTAssertNil(error)
      completionBlockCalledExpectation.fulfill()
    }

    rpc.handleResponse(data: "validString".data(using: .utf8)!, error: nil)
    wait(for: [completionBlockCalledExpectation], timeout: 1)
  }

  public func testNoDataAndErrorPassedToCompletionOnReceivingDataAndError() {
    let completionBlockCalledExpectation = XCTestExpectation(description: "Completion called")
    let rpc = TezosRPC(endpoint: "abc", responseAdapterClass: StringResponseAdapter.self) { data, error in
      XCTAssertNil(data)
      XCTAssertNotNil(error)
      completionBlockCalledExpectation.fulfill()
    }

    let error = TezosClientError(kind: .unknown, underlyingError: "")
    rpc.handleResponse(data: "validString".data(using: .utf8)!, error: error)
    wait(for: [completionBlockCalledExpectation], timeout: 1)
  }

  public func testErrorPassedToCompletionOnHandlingError() {
    let completionBlockCalledExpectation = XCTestExpectation(description: "Completion called")
    let rpc = TezosRPC(endpoint: "abc", responseAdapterClass: StringResponseAdapter.self) { data, error in
      XCTAssertNil(data)
      XCTAssertNotNil(error)
      completionBlockCalledExpectation.fulfill()
    }

    let error = TezosClientError(kind: .unknown, underlyingError: "")
    rpc.handleResponse(data: nil, error: error)

    wait(for: [completionBlockCalledExpectation], timeout: 1)
  }

  public func testErrorPassedToCompletionOnHandlingNilData() {
    let completionBlockCalledExpectation = XCTestExpectation(description: "Completion called")
    let rpc = TezosRPC(endpoint: "abc", responseAdapterClass: StringResponseAdapter.self) { data, error in
      XCTAssertNil(data)
      XCTAssertNotNil(error)
      completionBlockCalledExpectation.fulfill()
    }

    rpc.handleResponse(data: nil, error: nil)

    wait(for: [completionBlockCalledExpectation], timeout: 1)
  }

  public func testErrorPassedToCompletionOnHandlingInvalidData() {
    let completionBlockCalledExpectation = XCTestExpectation(description: "Completion called")
    let rpc = TezosRPC(endpoint: "abc", responseAdapterClass: IntegerResponseAdapter.self) { data, error in
      XCTAssertNil(data)
      XCTAssertNotNil(error)
      completionBlockCalledExpectation.fulfill()
    }

    rpc.handleResponse(data: "NotAnInteger".data(using: .utf8)!, error: nil)

    wait(for: [completionBlockCalledExpectation], timeout: 1)
  }
}
