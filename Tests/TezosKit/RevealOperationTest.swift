// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class RevealOperationTest: XCTestCase {
  public func testDictionaryRepresentation() {
    let source = "tz1abc"
    let publicKey = FakePublicKey(base58CheckRepresentation: "edpkXYZ")

    let operation = OperationFactory.testFactory.revealOperation(from: source, publicKey: publicKey, operationFees: nil)
    let dictionary = operation.dictionaryRepresentation

    XCTAssertNotNil(dictionary["source"])
    XCTAssertEqual(dictionary["source"] as? String, source)

    XCTAssertNotNil(dictionary["public_key"])
    XCTAssertEqual(dictionary["public_key"] as? String, publicKey.base58CheckRepresentation)
  }
}
