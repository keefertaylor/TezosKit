// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class GetBallotsRPCTest: XCTestCase {
  public func testGetBallotsRPC() {
    let rpc = GetBallotsRPC()

    XCTAssertEqual(rpc.endpoint, "chains/main/blocks/head/votes/ballots")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
