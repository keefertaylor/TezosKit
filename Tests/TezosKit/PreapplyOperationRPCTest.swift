// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class PreapplyOperationRPCTest: XCTestCase {
  public func testPreapplyOperationRPC() {
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

//("Optional("[{\"branch\":\"xyz\",\"contents\":[{}],\"protocol\":\"alpha\",\"signature\":\"abc123\"}]")")
//("Optional("{\"branch\":\"xyz\",\"contents\":[{}],\"protocol\":\"alpha\",\"signature\":\"abc123\"}")") -
