// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class GetVotingDelegateRightsRPCTest: XCTestCase {
  public func testGetVotingDelegateRightsRPC() {
    let rpc = GetVotingDelegateRightsRPC { _, _ in }

    XCTAssertEqual(rpc.endpoint, "chains/main/blocks/head/votes/listings")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
