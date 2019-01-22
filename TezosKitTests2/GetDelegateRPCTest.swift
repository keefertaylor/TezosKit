// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class GetDelegateRPCTest: XCTestCase {
  public func testGetDelegateRPC() {
    let address = "abc123"
    let rpc = GetDelegateRPC(address: address) { _, _ in }

    XCTAssertEqual(rpc.endpoint, "/chains/main/blocks/head/context/contracts/" + address + "/delegate")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
