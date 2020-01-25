// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class GetChainHeadRPCTest: XCTestCase {
  public func testGetChainHeadRPC() {
    let rpc = GetChainHeadRPC()

    XCTAssertEqual(rpc.endpoint, "/chains/main/blocks/head")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
