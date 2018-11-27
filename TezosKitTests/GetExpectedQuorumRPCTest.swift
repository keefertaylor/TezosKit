// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class GetExpectedQuorumRPCTest: XCTestCase {
  public func testGetExpectedQuorumRPCTest() {
    let rpc = GetExpectedQuorumRPC(blockID: 1000) { _, _ in }

    XCTAssertEqual(rpc.endpoint, "chains/main/blocks/1000/votes/current_quorum")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
