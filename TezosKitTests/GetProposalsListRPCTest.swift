// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class GetProposalsListRPCTest: XCTestCase {
  public func testGetProposalsListRPC() {
    let rpc = GetProposalsListRPC { _, _ in }

    XCTAssertEqual(rpc.endpoint, "chains/main/blocks/head/votes/proposals")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
