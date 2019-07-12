// Copyright Keefer Taylor, 2019.

@testable import TezosKit
import XCTest

class OperationPayloadTest: XCTestCase {
  /// Test a single operation with a revealed manager key.
  public func testOperationPayloadInitSingleOperation() {
    let addressCounter = 0

    let operation = RevealOperation(from: .testAddress, publicKey: .testPublicKey, operationFees: <#T##OperationFees#>)

    let metadata = OperationMetadata(
      branch: .testBranch,
      protocol: .testProtocol,
      addressCounter: addressCounter,
      key: .testPublicKey
    )

    let operationPayload = OperationPayload(operations: <#T##[Operation]#>, operationFactory: <#T##OperationFactory#>, operationMetadata: operationMetadata, source: .testAddress, signer: FakeSigner(signature: [1, 2, 3], publicKey: <#T##PublicKey#>))
  }

  public func testDictionaryRepresentation() {
    let dictionaryRepresentation = OperationPayload.testOperationPayload.dictionaryRepresentation

    XCTAssertEqual(dictionaryRepresentation["branch"] as? String, String.testBranch)
  }
}
