// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class GetChainHeadHashRPCTest: XCTestCase {
  public func testGetChainHeadHashRPC() {
    let rpc = GetChainHeadHashRPC { _, _ in }

    XCTAssertEqual(rpc.endpoint, "chains/main/blocks/head/hash")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
