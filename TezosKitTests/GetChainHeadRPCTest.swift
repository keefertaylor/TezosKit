// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class GetChainHeadRPCTest: XCTestCase {
  public func testGetChainHeadRPC() {
    let rpc = GetChainHeadRPC { _, _ in }

    XCTAssertEqual(rpc.endpoint, "chains/main/blocks/head")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
