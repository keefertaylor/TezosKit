// Copyright Keefer Taylor, 2019

import Foundation
import TezosCrypto
import XCTest

final class PublicKeyTests: XCTestCase {
  func testBase58CheckRepresentation() {
    guard let secretKey = SecretKey(mnemonic: .mnemonic) else {
      XCTFail()
      return
    }
    let publicKey = PublicKey(secretKey: secretKey, signingCurve: .ed25519)

    XCTAssertEqual(
      publicKey.base58CheckRepresentation,
      "edpku9ZF6UUAEo1AL3NWy1oxHLL6AfQcGYwA5hFKrEKVHMT3Xx889A"
    )
  }

  func testPublicKeyHash() {
    guard let secretKey = SecretKey(mnemonic: .mnemonic) else {
      XCTFail()
      return
    }
    let publicKey = PublicKey(secretKey: secretKey, signingCurve: .ed25519)

    XCTAssertEqual(
      publicKey.publicKeyHash,
      "tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw"
    )
  }

  func testInitFromBase58CheckRepresentation_ValidString() {
    let publicKeyFromString =
      PublicKey(string: "edpku9ZF6UUAEo1AL3NWy1oxHLL6AfQcGYwA5hFKrEKVHMT3Xx889A", signingCurve: .ed25519)
    XCTAssertNotNil(publicKeyFromString)

    guard let secretKey = SecretKey(mnemonic: .mnemonic) else {
      XCTFail()
      return
    }
    let publicKeyFromSecretKey = PublicKey(secretKey: secretKey, signingCurve: .ed25519)

    XCTAssertEqual(publicKeyFromString, publicKeyFromSecretKey)
  }

  func testInitFromBase58CheckRepresentation_InvalidBase58() {
    XCTAssertNil(
      PublicKey(string: "edsko0O", signingCurve: .ed25519)
    )
  }

  public func testVerifyHex() {
    let hexToSign = "123456"
    guard
      let secretKey1 = SecretKey(mnemonic: .mnemonic),
      let secretKey2 = SecretKey(mnemonic: "soccer soccer soccer soccer soccer soccer soccer soccer soccer")
    else {
      XCTFail()
      return
    }
    let publicKey1 = PublicKey(secretKey: secretKey1, signingCurve: .ed25519)
    let publicKey2 = PublicKey(secretKey: secretKey2, signingCurve: .ed25519)

    guard let signature = secretKey1.sign(hex: hexToSign) else {
      XCTFail()
      return
    }

    XCTAssertTrue(
      publicKey1.verify(signature: signature, hex: hexToSign)
    )
    XCTAssertFalse(
      publicKey2.verify(signature: signature, hex: hexToSign)
    )
    XCTAssertFalse(
      publicKey1.verify(signature: [1, 2, 3], hex: hexToSign)
    )
  }
}
