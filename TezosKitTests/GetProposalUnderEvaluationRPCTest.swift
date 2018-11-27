// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class GetProposalUnderEvaluationRPCTest: XCTestCase {
  public func testGetProposalUnderEvaluationRPC() {
    let rpc = GetProposalUnderEvaluationRPC { _, _ in }

    XCTAssertEqual(rpc.endpoint, "chains/main/blocks/head/votes/current_proposal")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
