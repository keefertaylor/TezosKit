// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

final class GetBigMapValueRPCTest: XCTestCase {
  func testGetBigMapValueRPC() {
    let michelsonAddress = StringMichelsonParameter(string: .testAddress)
    let rpc = GetBigMapValueRPC(address: .testAddress, key: michelsonAddress, type: .address)

    let expectedEndpoint = "/chains/main/blocks/head/context/contracts/\(String.testAddress)/big_map_get"
    let expectedPayload = "{\"key\":{\"string\":\"\(String.testAddress)\"},\"type\":{\"prim\":\"address\"}}"

    XCTAssertEqual(rpc.endpoint, expectedEndpoint)
    XCTAssertEqual(rpc.payload, Helpers.orderJSONString(expectedPayload))
    XCTAssertTrue(rpc.isPOSTRequest)
  }
}
