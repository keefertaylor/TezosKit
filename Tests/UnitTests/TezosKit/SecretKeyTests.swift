// Copyright Keefer Taylor, 2019

import Base58Swift
import Foundation
import TezosKit
import XCTest

final class SecretKeyTests: XCTestCase {

  // MARK: - ed25519

  func testBase58CheckRepresentation_ed25519() {
    guard let secretKey = SecretKey(mnemonic: .mnemonic, signingCurve: .ed25519) else {
      XCTFail()
      return
    }

    XCTAssertEqual(
      secretKey.base58CheckRepresentation,
      "edskS4pbuA7rwMjsZGmHU18aMP96VmjegxBzwMZs3DrcXHcMV7VyfQLkD5pqEE84wAMHzi8oVZF6wbgxv3FKzg7cLqzURjaXUp"
    )
  }

  func testInitFromBase58CheckRepresntation_ValidString_ed25519() {
    let secretKeyFromString = SecretKey(
      "edskS4pbuA7rwMjsZGmHU18aMP96VmjegxBzwMZs3DrcXHcMV7VyfQLkD5pqEE84wAMHzi8oVZF6wbgxv3FKzg7cLqzURjaXUp",
      signingCurve: .ed25519
    )
    XCTAssertNotNil(secretKeyFromString)

    guard let secretKeyFromMnemonic = SecretKey(mnemonic: .mnemonic, signingCurve: .ed25519) else {
      XCTFail()
      return
    }

    XCTAssertEqual(secretKeyFromString, secretKeyFromMnemonic)
  }

  func testInitFromBase58CheckRepresentation_InvalidBase58_ed25519() {
    XCTAssertNil(
      SecretKey("edsko0O", signingCurve: .ed25519)
    )
  }

  func testInvalidMnemonic_ed25519() {
    let invalidMnemonic =
      "TezosKit TezosKit TezosKit TezosKit TezosKit TezosKit TezosKit TezosKit TezosKit TezosKit TezosKit"
    XCTAssertNil(SecretKey(mnemonic: invalidMnemonic, signingCurve: .ed25519))
  }

  func testInvalidSeedString_ed25519() {
    let invalidSeedString = "abcdefghijklmnopqrstuvwxyz"
    XCTAssertNil(SecretKey(seedString: invalidSeedString, signingCurve: .ed25519))
  }

  public func testSignHex_ed25519() {
    let hexToSign = "deadbeef"
    guard let signature = SecretKey.testSecretKey_ed25519.sign(hex: hexToSign) else {
      XCTFail()
      return
    }

    XCTAssertEqual(
      signature,
      [
        208, 47, 19, 208, 168, 253, 44, 130, 231, 240, 15, 213, 223, 59, 178, 60, 130, 146, 175, 120, 119, 21, 237, 130,
        115, 88, 31, 213, 202, 126, 150, 205, 13, 237, 56, 251, 254, 240, 202, 228, 141, 180, 235, 175, 184, 189, 172,
        121, 43, 25, 235, 97, 235, 140, 144, 168, 32, 75, 190, 101, 126, 99, 117, 13
      ]
    )
  }

  public func testSignHexInvalid_ed25519() {
    let invalidHexString = "abcdefghijklmnopqrstuvwxyz"
    XCTAssertNil(SecretKey.testSecretKey_ed25519.sign(hex: invalidHexString))
  }

  // MARK: - secp256k1

  func testBase58CheckRepresentation_secp256k1() {
    guard let secretKey = SecretKey(mnemonic: .mnemonic, signingCurve: .secp256k1) else {
      XCTFail()
      return
    }

    XCTAssertEqual(
      secretKey.base58CheckRepresentation,
      "edskS4pbuA7rwMjsZGmHU18aMP96VmjegxBzwMZs3DrcXHcMV7VyfQLkD5pqEE84wAMHzi8oVZF6wbgxv3FKzg7cLqzURjaXUp"
    )
  }

  func testInitFromBase58CheckRepresntation_ValidString_secp256k1() {
    let base58Representation = "spsk2rBDDeUqakQ42nBHDGQTtP3GErb6AahHPwF9bhca3Q5KA5HESE"
    let secretKeyFromString =
      SecretKey(base58Representation, signingCurve: .secp256k1)
    XCTAssertNotNil(secretKeyFromString)
    XCTAssertEqual(secretKeyFromString?.base58CheckRepresentation, base58Representation)
  }

  func testInitFromBase58CheckRepresentation_InvalidBase58_secp256k1() {
    XCTAssertNil(
      SecretKey("edsko0O", signingCurve: .secp256k1)
    )
  }

  func testInvalidMnemonic_secp256k1() {
    let invalidMnemonic =
      "TezosKit TezosKit TezosKit TezosKit TezosKit TezosKit TezosKit TezosKit TezosKit TezosKit TezosKit"
    XCTAssertNil(SecretKey(mnemonic: invalidMnemonic, signingCurve: .secp256k1))
  }

  func testInvalidSeedString_secp256k1() {
    let invalidSeedString = "abcdefghijklmnopqrstuvwxyz"
    XCTAssertNil(SecretKey(seedString: invalidSeedString, signingCurve: .secp256k1))
  }

  public func testSignHex_secp256k1() {
    let expectedSignatureBase58 =
      "sigREwM1SuRN5WzjH5xGJuyeZQ9kWi8XtbA4wRqGTumJwNY18PmF1XQMLCXEQBr4frnriKHWdPUynF1vGUvPcoWrNjb3s5xp"

    guard
      let secretKey = SecretKey("spsk2rBDDeUqakQ42nBHDGQTtP3GErb6AahHPwF9bhca3Q5KA5HESE", signingCurve: .secp256k1),
      let signature = secretKey.sign(hex: "1234"),
      let expectedSignature = Base58.base58CheckDecodeWithPrefix(string: expectedSignatureBase58, prefix: [4, 130, 43])
    else {
      XCTFail()
      return
    }

    XCTAssertEqual(signature, expectedSignature)
  }
}
