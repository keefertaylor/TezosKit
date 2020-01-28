// Copyright Keefer Taylor, 2019

import Foundation
import TezosKit
import XCTest

final class PublicKeyTests: XCTestCase {

  // MARK: ed25519

  func testBase58CheckRepresentation_ed25519() {
    guard
      let secretKey = SecretKey(mnemonic: .mnemonic, signingCurve: .ed25519),
      let publicKey = PublicKey(secretKey: secretKey)
    else {
      XCTFail()
      return
    }

    XCTAssertEqual(
      publicKey.base58CheckRepresentation,
      "edpku9ZF6UUAEo1AL3NWy1oxHLL6AfQcGYwA5hFKrEKVHMT3Xx889A"
    )
  }

  func testPublicKeyHash_ed25519() {
    guard
      let secretKey = SecretKey(mnemonic: .mnemonic, signingCurve: .ed25519),
      let publicKey = PublicKey(secretKey: secretKey)
    else {
      XCTFail()
      return
    }

    XCTAssertEqual(
      publicKey.publicKeyHash,
      "tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw"
    )
  }

  func testInitFromBase58CheckRepresentation_ValidString_ed25519() {
    let publicKeyFromString =
      PublicKey(string: "edpku9ZF6UUAEo1AL3NWy1oxHLL6AfQcGYwA5hFKrEKVHMT3Xx889A", signingCurve: .ed25519)
    XCTAssertNotNil(publicKeyFromString)

    guard let secretKey = SecretKey(mnemonic: .mnemonic, signingCurve: .ed25519) else {
      XCTFail()
      return
    }
    let publicKeyFromSecretKey = PublicKey(secretKey: secretKey)

    XCTAssertEqual(publicKeyFromString, publicKeyFromSecretKey)
  }

  func testInitFromBase58CheckRepresentation_InvalidBase58_ed25519() {
    XCTAssertNil(
      PublicKey(string: "edsko0O", signingCurve: .ed25519)
    )
  }

  public func testVerifyHex_ed25519() {
    let hexToSign = "123456"
    guard
      let secretKey1 = SecretKey(mnemonic: .mnemonic, signingCurve: .ed25519),
      let secretKey2 = SecretKey(
        mnemonic: "soccer soccer soccer soccer soccer soccer soccer soccer soccer",
        signingCurve: .ed25519
      ),
      let publicKey1 = PublicKey(secretKey: secretKey1),
      let publicKey2 = PublicKey(secretKey: secretKey2)
    else {
      XCTFail()
      return
    }

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

  // MARK: secp256k1

  func testBase58CheckRepresentation_secp256k1() {
    let base58Representation = "sppk7aqSksZan1AGXuKtCz9UBLZZ77e3ZWGpFxR7ig1Z17GneEhSSbH"
    guard let publicKey = PublicKey(string: base58Representation, signingCurve: .secp256k1) else {
      XCTFail()
      return
    }
    XCTAssertEqual(publicKey.base58CheckRepresentation, base58Representation)
  }

  func testPublicKeyFromSecretKey_secp256k1() {
    guard
      let secretKey = SecretKey("spsk2rBDDeUqakQ42nBHDGQTtP3GErb6AahHPwF9bhca3Q5KA5HESE", signingCurve: .secp256k1),
      let publicKey = PublicKey(secretKey: secretKey)
    else {
      XCTFail()
      return
    }

    XCTAssertEqual(publicKey.base58CheckRepresentation, "sppk7aqSksZan1AGXuKtCz9UBLZZ77e3ZWGpFxR7ig1Z17GneEhSSbH")
  }

  func testPublicKeyHash_secp256k1() {
    let base58Representation = "sppk7aqSksZan1AGXuKtCz9UBLZZ77e3ZWGpFxR7ig1Z17GneEhSSbH"
    guard let publicKey = PublicKey(string: base58Representation, signingCurve: .secp256k1) else {
      XCTFail()
      return
    }
    XCTAssertEqual(publicKey.publicKeyHash, "tz2Ch1abG7FNiibmV26Uzgdsnfni9XGrk5wD")
 }

  func testInitFromBase58CheckRepresentation_InvalidBase58_secp256k1() {
    XCTAssertNil(
      PublicKey(string: "edsko0O", signingCurve: .secp256k1)
    )
  }

  public func testVerifyHex_secp256k1() {
    let hexToSign = "1234"

    guard
      let secretKey1 = SecretKey("spsk2rBDDeUqakQ42nBHDGQTtP3GErb6AahHPwF9bhca3Q5KA5HESE", signingCurve: .secp256k1),
      let secretKey2 = SecretKey(mnemonic: .mnemonic, signingCurve: .secp256k1),
      let validSignatureFromPublicKey1 = secretKey1.sign(hex: hexToSign),
      let publicKey1 = PublicKey(secretKey: secretKey1),
      let publicKey2 = PublicKey(secretKey: secretKey2)
    else {
      XCTFail()
      return
    }

    XCTAssertTrue(
      publicKey1.verify(signature: validSignatureFromPublicKey1, hex: hexToSign)
    )
    XCTAssertFalse(
      publicKey1.verify(signature: [1, 2, 3, 4], hex: hexToSign)
    )

    XCTAssertFalse(
      publicKey2.verify(signature: validSignatureFromPublicKey1, hex: hexToSign)
    )
  }

  // MARK: secp256k1

   func testBase58CheckRepresentation_p256() {
     let base58Representation = "p2pk66yEDuRC5RLHpVj8hvAS5fr8HnU2YsLvFNdwQoW3jH8WUynMwGG"
     guard let publicKey = PublicKey(string: base58Representation, signingCurve: .p256) else {
       XCTFail()
       return
     }
     XCTAssertEqual(publicKey.base58CheckRepresentation, base58Representation)
   }

   func testPublicKeyHash_p256() {
     let base58Representation = "p2pk66yEDuRC5RLHpVj8hvAS5fr8HnU2YsLvFNdwQoW3jH8WUynMwGG"
     guard let publicKey = PublicKey(string: base58Representation, signingCurve: .p256) else {
       XCTFail()
       return
     }
     XCTAssertEqual(publicKey.publicKeyHash, "tz3Q2KTKWw3xqiowvfX4N7gyyAfCz8hTvcnk")
  }

   func testInitFromBase58CheckRepresentation_InvalidBase58_p256() {
     XCTAssertNil(
       PublicKey(string: "edsko0O", signingCurve: .p256)
     )
   }
}
