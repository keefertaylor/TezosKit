// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class GetBallotsRPCTest: XCTestCase {
  public func testGetBallotsRPC() {
    let rpc = GetBallotsRPC { _, _ in }

    XCTAssertEqual(rpc.endpoint, "chains/main/blocks/head/votes/ballots")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
