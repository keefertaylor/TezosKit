// Copyright Keefer Taylor, 2019

import TezosCrypto
import XCTest

// swiftlint:disable todo
// TODO: Re-enable

class TezosCryptoTests: XCTestCase {
  public func testValidateAddress() {
    let validAddress = "tz1PnyUZjRTFdYbYcJFenMwZanXtVP17scPH"
    let validOriginatedAddress = "KT1Agon3ARPS7U74UedWpR96j1CCbPCsSTsL"
    let invalidAddress = "tz1PnyUZjRTFdYbYcJFenMwZanXtVP17scPh"
    let publicKey = "edpkvESBNf3cbx7sb4CjyurMxFJjCkUVkunDMjsXD4Squoo5nJR4L4"
    let nonBase58Address = "tz10ol1OLscph"

    XCTAssertTrue(TezosCryptoUtils.validateAddress(address: validAddress))
    XCTAssertFalse(TezosCryptoUtils.validateAddress(address: validOriginatedAddress))
    XCTAssertFalse(TezosCryptoUtils.validateAddress(address: invalidAddress))
    XCTAssertFalse(TezosCryptoUtils.validateAddress(address: publicKey))
    XCTAssertFalse(TezosCryptoUtils.validateAddress(address: nonBase58Address))
  }

  public func testBase58Representation() {
    let signature: [UInt8] =
      [
        208, 47, 19, 208, 168, 253, 44, 130, 231, 240, 15, 213, 223, 59, 178, 60, 130, 146, 175, 120, 119, 21, 237, 130,
        115, 88, 31, 213, 202, 126, 150, 205, 13, 237, 56, 251, 254, 240, 202, 228, 141, 180, 235, 175, 184, 189, 172,
        121, 43, 25, 235, 97, 235, 140, 144, 168, 32, 75, 190, 101, 126, 99, 117, 13
      ]

    let base58Representation = TezosCryptoUtils.base58(signature: signature)
    XCTAssertEqual(
      base58Representation,
      "edsigu13UN5tAjQsxaLmXL7vCXM9BRggVDygne5LDZs7fHNH61PXfgbmXaAAq63GR8gqgeqa3aYNH4dnv18LdHaSCetC9sSJUCF"
    )
  }

  public func testHexToBin() {
    XCTAssertEqual(TezosCryptoUtils.hexToBin("1234"), [18, 52])
  }

  public func testBinToHex() {
    XCTAssertEqual(TezosCryptoUtils.binToHex([18, 52]), "1234")
  }

  public func testInjectableBytes() {
    let hex = "deadbeef"
    let signature: [UInt8] = [18, 52]
    XCTAssertEqual(TezosCryptoUtils.injectableHex(hex, signature: signature), "deadbeef1234")
  }
}
