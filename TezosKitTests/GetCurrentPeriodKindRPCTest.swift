// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class GetCurrentPeriodKindRPCTest: XCTestCase {
  public func testGetCurrentPeriodKindRPC() {
    let rpc = GetCurrentPeriodKindRPC(blockID: 1000) { _, _ in }

    XCTAssertEqual(rpc.endpoint, "chains/main/blocks/1000/votes/current_period_kind")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
