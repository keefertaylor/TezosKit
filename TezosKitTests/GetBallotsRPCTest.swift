// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class GetBallotsRPCTest: XCTestCase {
  public func testGetBallotsRPC() {
    let rpc = GetBallotsRPC(blockID: 1000) { _, _ in }

    XCTAssertEqual(rpc.endpoint, "chains/main/blocks/1000/votes/ballots")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
