// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class InjectOperationRPCTest: XCTestCase {
  public func testInjectRPC() {
    let payload = "payload"
    let rpc = InjectionRPC(payload: payload) { _, _ in }

    XCTAssertEqual(rpc.endpoint, "/injection/operation")
    XCTAssertEqual(rpc.payload, payload)
    XCTAssertTrue(rpc.isPOSTRequest)
  }
}
