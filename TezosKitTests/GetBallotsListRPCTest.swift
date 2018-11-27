// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class GetBallotsListRPCTest: XCTestCase {
  public func testGetBallotsListRPC() {
    let rpc = GetChainHeadRPC { _, _ in }

    XCTAssertEqual(rpc.endpoint, "chains/main/blocks/head")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
