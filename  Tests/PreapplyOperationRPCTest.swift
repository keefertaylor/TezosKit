// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class PreapplyOperationRPCTest: XCTestCase {
  public func testPreapplyOperationRPC() {
    let chainID = "abc123"
    let headHash = "xyz"
    let payload = "payload"
    let rpc = PreapplyOperationRPC(chainID: chainID, headHash: headHash, payload: payload) { _, _ in }

    XCTAssertEqual(rpc.endpoint, "chains/" + chainID + "/blocks/" + headHash + "/helpers/preapply/operations")
    XCTAssertEqual(rpc.payload, payload)
    XCTAssertTrue(rpc.isPOSTRequest)
  }
}
