// Copyright Keefer Taylor, 2019

import TezosKit
import XCTest

class CryptoUtilsTest: XCTestCase {
  public func testValidateAddress() {
    let validAddress = "tz1PnyUZjRTFdYbYcJFenMwZanXtVP17scPH"
    let validOriginatedAddress = "KT1Agon3ARPS7U74UedWpR96j1CCbPCsSTsL"
    let invalidAddress = "tz1PnyUZjRTFdYbYcJFenMwZanXtVP17scPh"
    let publicKey = "edpkvESBNf3cbx7sb4CjyurMxFJjCkUVkunDMjsXD4Squoo5nJR4L4"
    let nonBase58Address = "tz10ol1OLscph"

    XCTAssertTrue(CryptoUtils.validateAddress(address: validAddress))
    XCTAssertFalse(CryptoUtils.validateAddress(address: validOriginatedAddress))
    XCTAssertFalse(CryptoUtils.validateAddress(address: invalidAddress))
    XCTAssertFalse(CryptoUtils.validateAddress(address: publicKey))
    XCTAssertFalse(CryptoUtils.validateAddress(address: nonBase58Address))
  }

  public func testBase58Representation() {
    let signature: [UInt8] =
      [
        208, 47, 19, 208, 168, 253, 44, 130, 231, 240, 15, 213, 223, 59, 178, 60, 130, 146, 175, 120, 119, 21, 237, 130,
        115, 88, 31, 213, 202, 126, 150, 205, 13, 237, 56, 251, 254, 240, 202, 228, 141, 180, 235, 175, 184, 189, 172,
        121, 43, 25, 235, 97, 235, 140, 144, 168, 32, 75, 190, 101, 126, 99, 117, 13
      ]

    let base58Representation = CryptoUtils.base58(signature: signature, signingCurve: .ed25519)
    XCTAssertEqual(
      base58Representation,
      "edsigu13UN5tAjQsxaLmXL7vCXM9BRggVDygne5LDZs7fHNH61PXfgbmXaAAq63GR8gqgeqa3aYNH4dnv18LdHaSCetC9sSJUCF"
    )
  }

  public func testHexToBin() {
    XCTAssertEqual(CryptoUtils.hexToBin("1234"), [18, 52])
  }

  public func testBinToHex() {
    XCTAssertEqual(CryptoUtils.binToHex([18, 52]), "1234")
  }

  public func testInjectableBytes() {
    let hex = "deadbeef"
    let signature: [UInt8] = [18, 52]
    XCTAssertEqual(CryptoUtils.injectableHex(hex, signature: signature), "deadbeef1234")
  }

  public func testCompressKey_oddParity() {
    guard
      let uncompressedBytes = CryptoUtils.hexToBin(
        "0414fc03b8df87cd7b872996810db8458d61da8448e531569c8517b469a119d267be5645686309c6e6736dbd93940707cc9143d3cf29f1b877ff340e2cb2d259cf"
      ),
      let expectedCompressedBytes = CryptoUtils.hexToBin("0314fc03b8df87cd7b872996810db8458d61da8448e531569c8517b469a119d267")
    else {
      XCTFail()
      return
    }

    XCTAssertEqual(CryptoUtils.compressKey(uncompressedBytes), expectedCompressedBytes)
  }

  public func testCompressKey_evenParity() {
    guard
      let uncompressedBytes = CryptoUtils.hexToBin(
        "0414fc03b8df87cd7b872996810db8458d61da8448e531569c8517b469a119d267be5645686309c6e6736dbd93940707cc9143d3cf29f1b877ff340e2cb2d259ce"
      ),
      let expectedCompressedBytes = CryptoUtils.hexToBin("0214fc03b8df87cd7b872996810db8458d61da8448e531569c8517b469a119d267")
    else {
      XCTFail()
      return
    }

    XCTAssertEqual(CryptoUtils.compressKey(uncompressedBytes), expectedCompressedBytes)
  }

  public func testCompressKey_badLength() {
    guard
      let uncompressedBytes = CryptoUtils.hexToBin("00")
    else {
      XCTFail()
      return
    }

    XCTAssertNil(CryptoUtils.compressKey(uncompressedBytes))
  }

  public func testCompressKey_badMagicByte() {
    guard
      let uncompressedBytes = CryptoUtils.hexToBin(
        "0214fc03b8df87cd7b872996810db8458d61da8448e531569c8517b469a119d267be5645686309c6e6736dbd93940707cc9143d3cf29f1b877ff340e2cb2d259ce"
      )
    else {
      XCTFail()
      return
    }

    XCTAssertNil(CryptoUtils.compressKey(uncompressedBytes))
  }
}
