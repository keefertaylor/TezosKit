// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

// TODO(keefertaylor): Merge in crypto tests.

class SignedOperationPayloadTest: XCTestCase {
  public func testDictionaryRepresentation() {
    let dictionaryRepresentation = SignedOperationPayload.testSignedOperationPayload.dictionaryRepresentation
    XCTAssertEqual(
      dictionaryRepresentation["signature"] as? String,
      CryptoUtils.base58(signature: .testSignature, signingCurve: .ed25519)
    )
  }
}
