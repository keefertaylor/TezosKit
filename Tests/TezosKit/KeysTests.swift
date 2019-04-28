// Copyright Keefer Taylor, 2018

@testable import TezosKit
import XCTest

class KeysTests: XCTestCase {
  public func testEquality() {
    let fakePublicKey1 = FakePublicKey(base58CheckRepresentation: "a")
    let fakeSecretKey1 = FakeSecretKey(base58CheckRepresentation: "b")

    let fakePublicKey2 = FakePublicKey(base58CheckRepresentation: "a")
    let fakeSecretKey2 = FakeSecretKey(base58CheckRepresentation: "b")

    let keys1 = Keys(publicKey: fakePublicKey1, secretKey: fakeSecretKey1)
    let keys2 = Keys(publicKey: fakePublicKey2, secretKey: fakeSecretKey2)
    XCTAssertEqual(keys1, keys2)

    let fakePublicKey3 = FakePublicKey(base58CheckRepresentation: "b")
    let fakeSecretKey3 = FakeSecretKey(base58CheckRepresentation: "b")

    let keys3 = Keys(publicKey: fakePublicKey3, secretKey: fakeSecretKey3)
    XCTAssertNotEqual(keys1, keys3)

    let fakePublicKey4 = FakePublicKey(base58CheckRepresentation: "a")
    let fakeSecretKey4 = FakeSecretKey(base58CheckRepresentation: "a")

    let keys4 = Keys(publicKey: fakePublicKey4, secretKey: fakeSecretKey4)
    XCTAssertNotEqual(keys1, keys4)
  }
}
