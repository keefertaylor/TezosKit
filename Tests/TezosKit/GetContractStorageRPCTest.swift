// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

final class GetContractStorageRPCTest: XCTestCase {
  func testGetContractStorageRPC() {
    let address = "abc123"
    let rpc = GetContractStorageRPC(address: address)

    XCTAssertEqual(rpc.endpoint, "/chains/main/blocks/head/context/contracts/\(address)/storage")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
