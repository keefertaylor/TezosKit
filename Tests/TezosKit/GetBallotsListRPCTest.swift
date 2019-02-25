// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class GetBallotsListRPCTest: XCTestCase {
  public func testGetBallotsListRPC() {
    let rpc = GetChainHeadRPC()

    XCTAssertEqual(rpc.endpoint, "chains/main/blocks/head")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
