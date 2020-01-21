// Copyright Keefer Taylor, 2019

import Foundation
import TezosCrypto
import XCTest

final class SecretKeyTests: XCTestCase {
  func testBase58CheckRepresentation() {
    guard let secretKey = SecretKey(mnemonic: .mnemonic) else {
      XCTFail()
      return
    }

    XCTAssertEqual(
      secretKey.base58CheckRepresentation,
      "edskS4pbuA7rwMjsZGmHU18aMP96VmjegxBzwMZs3DrcXHcMV7VyfQLkD5pqEE84wAMHzi8oVZF6wbgxv3FKzg7cLqzURjaXUp"
    )
  }

  func testInitFromBase58CheckRepresntation_ValidString() {
    let secretKeyFromString =
      SecretKey("edskS4pbuA7rwMjsZGmHU18aMP96VmjegxBzwMZs3DrcXHcMV7VyfQLkD5pqEE84wAMHzi8oVZF6wbgxv3FKzg7cLqzURjaXUp")
    XCTAssertNotNil(secretKeyFromString)

    guard let secretKeyFromMnemonic = SecretKey(mnemonic: .mnemonic) else {
      XCTFail()
      return
    }

    XCTAssertEqual(secretKeyFromString, secretKeyFromMnemonic)
  }

  func testInitFromBase58CheckRepresentation_InvalidBase58() {
    XCTAssertNil(
      SecretKey("edsko0O")
    )
  }

  func testInvalidMnemonic() {
    let invalidMnemonic =
      "TezosKit TezosKit TezosKit TezosKit TezosKit TezosKit TezosKit TezosKit TezosKit TezosKit TezosKit"
    XCTAssertNil(SecretKey(mnemonic: invalidMnemonic))
  }

  func testInvalidSeedString() {
    let invalidSeedString = "abcdefghijklmnopqrstuvwxyz"
    XCTAssertNil(SecretKey(seedString: invalidSeedString))
  }

  public func testSignHex() {
    let hexToSign = "deadbeef"
    guard let signature = SecretKey.testSecretKey.sign(hex: hexToSign) else {
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

  public func testSignHexInvalid() {
    let invalidHexString = "abcdefghijklmnopqrstuvwxyz"
    XCTAssertNil(SecretKey.testSecretKey.sign(hex: invalidHexString))
  }
}
