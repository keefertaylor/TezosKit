// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class GetBallotsListRPCTest: XCTestCase {
  public func testGetBallotsListRPC() {
    let rpc = GetBallotsListRPC()

    XCTAssertEqual(rpc.endpoint, "/chains/main/blocks/head/votes/ballot_list")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
