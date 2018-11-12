// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class GetAddressBalanceRPCTest: XCTestCase {
  public func testGetAddressBalanceRPC() {
    let address = "abc123"
    let rpc = GetAddressBalanceRPC(address: address) { _, _ in }

    XCTAssertEqual(rpc.endpoint, "/chains/main/blocks/head/context/contracts/" + address + "/balance")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
