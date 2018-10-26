import XCTest
import TezosKit

class CryptoTests: XCTestCase {
  private let mnemonic  = "soccer click number muscle police corn couch bitter gorilla camp camera shove expire praise pill"
  private let passphrase = "TezosKitTest"

  // Expected outputs for a wallet without a passphrase.
  let expectedPublicKeyNoPassphrase = "edpku9ZF6UUAEo1AL3NWy1oxHLL6AfQcGYwA5hFKrEKVHMT3Xx889A"
  let expectedSecretKeyNoPassphrase = "edskS4pbuA7rwMjsZGmHU18aMP96VmjegxBzwMZs3DrcXHcMV7VyfQLkD5pqEE84wAMHzi8oVZF6wbgxv3FKzg7cLqzURjaXUp"
  let expectedPublicKeyHashNoPassphrase = "tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw"

  public func testExtractPublicKey() {
    guard let key = Crypto.extractPublicKey(secretKey: expectedSecretKeyNoPassphrase) else {
      XCTFail()
      return
    }
    XCTAssertEqual(key, expectedPublicKeyNoPassphrase)
  }

  public func testExtractPublicKeyHash() {
    guard let key = Crypto.extractPublicKeyHash(secretKey: expectedSecretKeyNoPassphrase) else {
      XCTFail()
      return
    }
    XCTAssertEqual(key, expectedPublicKeyHashNoPassphrase)
  }

  public func testExtractPublicKeyAndPublicKeyHashWithBadSecretKey() {
    let incorrectSecretKey = "Incorrect"
    let publicKey = Crypto.extractPublicKey(secretKey: incorrectSecretKey)
    let publicKeyHash = Crypto.extractPublicKeyHash(secretKey: incorrectSecretKey)

    XCTAssertNil(publicKey)
    XCTAssertNil(publicKeyHash)
  }

  public func testValidateAddress() {
    let validAddress = "tz1PnyUZjRTFdYbYcJFenMwZanXtVP17scPH"
    let validOriginatedAddress = "KT1Agon3ARPS7U74UedWpR96j1CCbPCsSTsL"
    let invalidAddress = "tz1PnyUZjRTFdYbYcJFenMwZanXtVP17scPh"
    let publicKey = "edpkvESBNf3cbx7sb4CjyurMxFJjCkUVkunDMjsXD4Squoo5nJR4L4"

    XCTAssertTrue(Crypto.validateAddress(address: validAddress))
    XCTAssertFalse(Crypto.validateAddress(address: validOriginatedAddress))
    XCTAssertFalse(Crypto.validateAddress(address: invalidAddress))
    XCTAssertFalse(Crypto.validateAddress(address: publicKey))
  }
}
