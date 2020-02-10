// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class RevealOperationTest: XCTestCase {
  public func testDictionaryRepresentation() {
    let publicKey = FakePublicKey.testPublicKey

    guard case let .success(operation) = OperationFactory.testFactory.revealOperation(
      from: publicKey.publicKeyHash,
      publicKey: publicKey,
      operationFeePolicy: .default,
      signatureProvider: FakeSignatureProvider.testSignatureProvider
    ) else {
      XCTFail()
      return
    }
    let dictionary = operation.dictionaryRepresentation

    XCTAssertNotNil(dictionary["source"])
    XCTAssertEqual(dictionary["source"] as? String, publicKey.publicKeyHash)

    XCTAssertNotNil(dictionary["public_key"])
    XCTAssertEqual(dictionary["public_key"] as? String, publicKey.base58CheckRepresentation)
  }
}
