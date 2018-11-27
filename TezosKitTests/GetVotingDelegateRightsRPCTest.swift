// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class GetVotingDelegateRightsRPCTest: XCTestCase {
  public func testGetVotingDelegateRightsRPC() {
    let rpc = GetVotingDelegateRightsRPC(blockID: 1000) { _, _ in }

    XCTAssertEqual(rpc.endpoint, "chains/main/blocks/1000/votes/listings")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
