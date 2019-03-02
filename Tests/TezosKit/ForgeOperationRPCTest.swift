// Copyright Keefer Taylor, 2018

@testable import TezosKit
import XCTest

class ForgeOperationRPCTest: XCTestCase {
  public func testForgeOperationRPC() {
    let rpc = ForgeOperationRPC(operationPayload: .testOperationPayload, operationMetadata: .testOperationMetadata)

    let expectedEndpoint =
      "/chains/" + OperationMetadata.testOperationMetadata.chainID + "/blocks/" +
        OperationMetadata.testOperationMetadata.branch + "/helpers/forge/operations"
    let expectedPayload = JSONUtils.jsonString(for: OperationPayload.testOperationPayload.dictionaryRepresentation)

    XCTAssertEqual(rpc.endpoint, expectedEndpoint)
    XCTAssertEqual(rpc.payload, expectedPayload)
    XCTAssertTrue(rpc.isPOSTRequest)
  }
}
