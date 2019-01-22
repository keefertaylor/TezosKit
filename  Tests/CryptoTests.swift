// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class CryptoTests: XCTestCase {
  private let mnemonic = "soccer click number muscle police corn couch bitter gorilla camp camera shove expire praise pill"
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
    let nonBase58Address = "tz10ol1OLscph"

    XCTAssertTrue(Crypto.validateAddress(address: validAddress))
    XCTAssertFalse(Crypto.validateAddress(address: validOriginatedAddress))
    XCTAssertFalse(Crypto.validateAddress(address: invalidAddress))
    XCTAssertFalse(Crypto.validateAddress(address: publicKey))
    XCTAssertFalse(Crypto.validateAddress(address: nonBase58Address))
  }

  public func testVerifyBytes() {
    let fakeOperation = "123456"
    let wallet = Wallet()!
    let randomWallet = Wallet()!
    let result = Crypto.signForgedOperation(operation: fakeOperation, secretKey: wallet.keys.secretKey)!

    XCTAssertTrue(Crypto.verifyBytes(bytes: result.operationBytes, signature: result.signature, publicKey: wallet.keys.publicKey))
    XCTAssertFalse(Crypto.verifyBytes(bytes: result.operationBytes, signature: result.signature, publicKey: randomWallet.keys.publicKey))
    XCTAssertFalse(Crypto.verifyBytes(bytes: result.operationBytes, signature: [1, 2, 3], publicKey: wallet.keys.publicKey))
  }

  public func testSignForgedOperation() {
    let operation = "deadbeef"
    guard let result = Crypto.signForgedOperation(operation: operation, secretKey: expectedSecretKeyNoPassphrase) else {
      XCTFail()
      return
    }

    XCTAssertEqual(result.signature, [208, 47, 19, 208, 168, 253, 44, 130, 231, 240, 15, 213, 223, 59, 178, 60, 130, 146, 175, 120, 119, 21, 237, 130, 115, 88, 31, 213, 202, 126, 150, 205, 13, 237, 56, 251, 254, 240, 202, 228, 141, 180, 235, 175, 184, 189, 172, 121, 43, 25, 235, 97, 235, 140, 144, 168, 32, 75, 190, 101, 126, 99, 117, 13])
    XCTAssertEqual(result.sbytes, "deadbeefd02f13d0a8fd2c82e7f00fd5df3bb23c8292af787715ed8273581fd5ca7e96cd0ded38fbfef0cae48db4ebafb8bdac792b19eb61eb8c90a8204bbe657e63750d")
    XCTAssertEqual(result.edsig, "edsigu13UN5tAjQsxaLmXL7vCXM9BRggVDygne5LDZs7fHNH61PXfgbmXaAAq63GR8gqgeqa3aYNH4dnv18LdHaSCetC9sSJUCF")
    XCTAssertEqual(result.operationBytes,
                   [157, 20, 81, 191, 15, 135, 239, 179, 10, 160, 229, 185, 145, 23, 78, 66, 127, 4, 124, 81, 94, 40, 28, 90, 237, 88, 213, 226, 125, 40, 11, 153])
  }

  public func testKeyPairFromSeedString() {
    let validSeedString = "cce78b57ed8f4ec6767ed35f3aa41df525a03455e24bcc45a8518f63fbeda772"
    guard let keyPair = Crypto.keyPair(from: validSeedString) else {
      XCTFail()
      return
    }
    XCTAssertEqual(keyPair.publicKey, [66, 154, 152, 108, 128, 114, 164, 10, 31, 58, 62, 42, 181, 165, 129, 155, 177, 178, 251, 105, 153, 60, 80, 4, 131, 120, 21, 185, 220, 85, 146, 62])
    XCTAssertEqual(keyPair.secretKey, [204, 231, 139, 87, 237, 143, 78, 198, 118, 126, 211, 95, 58, 164, 29, 245, 37, 160, 52, 85, 226, 75, 204, 69, 168, 81, 143, 99, 251, 237, 167, 114, 66, 154, 152, 108, 128, 114, 164, 10, 31, 58, 62, 42, 181, 165, 129, 155, 177, 178, 251, 105, 153, 60, 80, 4, 131, 120, 21, 185, 220, 85, 146, 62])

    let invalidSeedString = "123xyzDefinitelyNotHexEncoded"
    let invalidKeyPair = Crypto.keyPair(from: invalidSeedString)
    XCTAssertNil(invalidKeyPair)
  }

  public func testTezosPublicKeyFromKey() {
    let validInputKey: [UInt8] = [66, 154, 152, 108, 128, 114, 164, 10, 31, 58, 62, 42, 181, 165, 129, 155, 177, 178, 251, 105, 153, 60, 80, 4, 131, 120, 21, 185, 220, 85, 146, 62]
    guard let publicKey = Crypto.tezosPublicKey(from: validInputKey) else {
      XCTFail()
      return
    }
    XCTAssertEqual(publicKey, "edpku9ZF6UUAEo1AL3NWy1oxHLL6AfQcGYwA5hFKrEKVHMT3Xx889A")
  }

  public func testTezosSecretKeyFromKey() {
    let validInputKey: [UInt8] = [204, 231, 139, 87, 237, 143, 78, 198, 118, 126, 211, 95, 58, 164, 29, 245, 37, 160, 52, 85, 226, 75, 204, 69, 168, 81, 143, 99, 251, 237, 167, 114, 66, 154, 152, 108, 128, 114, 164, 10, 31, 58, 62, 42, 181, 165, 129, 155, 177, 178, 251, 105, 153, 60, 80, 4, 131, 120, 21, 185, 220, 85, 146, 62]
    guard let secretKey = Crypto.tezosSecretKey(from: validInputKey) else {
      XCTFail()
      return
    }
    XCTAssertEqual(secretKey, "edskS4pbuA7rwMjsZGmHU18aMP96VmjegxBzwMZs3DrcXHcMV7VyfQLkD5pqEE84wAMHzi8oVZF6wbgxv3FKzg7cLqzURjaXUp")
  }

  public func testTezosPublicHashKeyFromKey() {
    let validInputKey: [UInt8] = [66, 154, 152, 108, 128, 114, 164, 10, 31, 58, 62, 42, 181, 165, 129, 155, 177, 178, 251, 105, 153, 60, 80, 4, 131, 120, 21, 185, 220, 85, 146, 62]
    guard let publicKeyHash = Crypto.tezosPublicKeyHash(from: validInputKey) else {
      XCTFail()
      return
    }
    XCTAssertEqual(publicKeyHash, "tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw")
  }
}
