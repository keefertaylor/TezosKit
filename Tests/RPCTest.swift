// Copyright Keefer Taylor, 2018

@testable import TezosKit
import XCTest

class RPCTest: XCTestCase {
  public func testIsPOSTRequest() {
    let getRPC = RPC(endpoint: "a", responseAdapterClass: StringResponseAdapter.self)
    XCTAssertFalse(getRPC.isPOSTRequest)

    let postRPC = RPC(endpoint: "a", responseAdapterClass: StringResponseAdapter.self, payload: "abc")
    XCTAssertTrue(postRPC.isPOSTRequest)
  }
}
