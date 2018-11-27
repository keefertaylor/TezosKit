// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class GetProposalUnderEvaluationRPCTest: XCTestCase {
  public func testGetProposalUnderEvaluationRPC() {
    let rpc = GetProposalUnderEvaluationRPC(blockID: 1000) { _, _ in }

    XCTAssertEqual(rpc.endpoint, "chains/main/blocks/1000/votes/current_proposal")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
