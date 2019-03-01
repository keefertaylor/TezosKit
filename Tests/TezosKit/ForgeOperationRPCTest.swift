// Copyright Keefer Taylor, 2018

@testable import TezosKit
import XCTest

class ForgeOperationRPCTest: XCTestCase {
  public func testForgeOperationRPC() {
    let chainID = "abc123"
    let headHash = "xyz"
    let payload = "payload"
    let rpc = ForgeOperationRPC(operationPayload: .testOperationPayload, operationMetadata: .testOperationMetadata)

    XCTAssertEqual(rpc.endpoint, "/chains/" + chainID + "/blocks/" + headHash + "/helpers/forge/operations")
    XCTAssertEqual(rpc.payload, payload)
    XCTAssertTrue(rpc.isPOSTRequest)
  }
}
