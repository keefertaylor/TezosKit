// Copyright Keefer Taylor, 2019

import XCTest

@testable import TezosKit

class RunOperationRPCTest: XCTestCase {
  public func testForgeOperationRPC() {
    let rpc = RunOperationRPC(runOperationPayload: .testRunOperationPayload)

    let expectedEndpoint =
      "/chains/main/blocks/head/helpers/scripts/run_operation"
    let expectedPayload =
      JSONUtils.jsonString(for: RunOperationPayload.testRunOperationPayload.dictionaryRepresentation)

    XCTAssertEqual(rpc.endpoint, expectedEndpoint)
    XCTAssertEqual(rpc.payload, expectedPayload)
    XCTAssertTrue(rpc.isPOSTRequest)
  }
}
