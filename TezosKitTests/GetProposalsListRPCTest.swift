// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class GetProposalsListRPCTest: XCTestCase {
  public func testGetProposalsListRPC() {
    let rpc = GetProposalsListRPC(blockID: 1000) { _, _ in }

    XCTAssertEqual(rpc.endpoint, "chains/main/blocks/1000/votes/proposals")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
