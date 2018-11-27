// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class GetExpectedQuorumRPCTest: XCTestCase {
  public func testGetExpectedQuorumRPCTest() {
    let rpc = GetExpectedQuorumRPC { _, _ in }

    XCTAssertEqual(rpc.endpoint, "chains/main/blocks/head/votes/current_quorum")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
