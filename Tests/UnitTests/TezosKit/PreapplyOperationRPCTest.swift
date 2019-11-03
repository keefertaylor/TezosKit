// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

final class PreapplyOperationRPCTest: XCTestCase {
  func testPreapplyOperationRPC() {
    let rpc = PreapplyOperationRPC(
      signedProtocolOperationPayload: .testSignedProtocolOperationPayload,
      operationMetadata: .testOperationMetadata
    )

    let expectedEndpoint =
      "/chains/main/blocks/" + OperationMetadata.testOperationMetadata.branch + "/helpers/preapply/operations"
    let expectedPayloadDictionary =
      SignedProtocolOperationPayload.testSignedProtocolOperationPayload.dictionaryRepresentation
    let expectedPayload = JSONUtils.jsonString(for: expectedPayloadDictionary)

    XCTAssertEqual(rpc.endpoint, expectedEndpoint)
    XCTAssertEqual(rpc.payload, expectedPayload)
    XCTAssertTrue(rpc.isPOSTRequest)
  }
}
