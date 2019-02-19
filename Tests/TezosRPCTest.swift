// Copyright Keefer Taylor, 2018

@testable import TezosKit
import XCTest

class TezosRPCTest: XCTestCase {
  public func testIsPOSTRequest() {
    let getRPC = TezosRPC(
      endpoint: "a",
      responseAdapterClass: StringResponseAdapter.self
    ) { _, _ in
    }
    XCTAssertFalse(getRPC.isPOSTRequest)

    let postRPC = TezosRPC(
      endpoint: "a",
      responseAdapterClass: StringResponseAdapter.self,
      payload: "abc"
    ) { _, _ in
    }

    XCTAssertTrue(postRPC.isPOSTRequest)
  }
}
