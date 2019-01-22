// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class MnemonicUtilsTest: XCTestCase {
  // Mnemonic and Passphrase for tests.
  private let mnemonic = "soccer click number muscle police corn couch bitter gorilla camp camera shove expire praise pill"
  private let passphrase = "TezosKitTests"

  // Expected seed strings with / without passphrase.
  private let expectedSeedStringNoPassphrase = "cce78b57ed8f4ec6767ed35f3aa41df525a03455e24bcc45a8518f63fbeda772"
  private let expectedSeedStringWithPassphrase = "cc90fecd0a596e2cd41798612682395faa2ebfe18945a88c6f01e4bfab17c3e3"

  // Mnemonic generation should always succeed.
  public func testGenerateMnemonic() {
    let result = MnemonicUtil.generateMnemonic()
    XCTAssertNotNil(result)
  }

  public func testSeedStringFromMnemonicNoPassphrase() {
    guard let result = MnemonicUtil.seedString(from: mnemonic) else {
      fatalError()
    }
    XCTAssertEqual(result, expectedSeedStringNoPassphrase)
  }

  public func testSeedStringFromMnemonicEmptyPassphrase() {
    guard let result = MnemonicUtil.seedString(from: mnemonic, passphrase: "") else {
      fatalError()
    }

    // Empty passphrase should be the same as no passphrase.
    XCTAssertEqual(result, expectedSeedStringNoPassphrase)
  }

  public func testSeedStringFromMnemonicWithPassphrase() {
    guard let result = MnemonicUtil.seedString(from: mnemonic, passphrase: passphrase) else {
      fatalError()
    }

    // Empty passphrase should be the same as no passphrase.
    XCTAssertEqual(result, expectedSeedStringWithPassphrase)
  }

  public func testValidateMnemonic() {
    // Valid mnemonic.
    let validMnemonic =
      "pear peasant pelican pen pear peasant pelican pen pear peasant pelican pen pear peasant pelican pen"
    XCTAssertTrue(MnemonicUtil.validate(mnemonic: validMnemonic))

    // Invalid mnemonic.
    let invalidMnemonic = "slacktivist snacktivity snuggie"
    XCTAssertFalse(MnemonicUtil.validate(mnemonic: invalidMnemonic))

    // Empty string should be invalid.
    XCTAssertFalse(MnemonicUtil.validate(mnemonic: ""))

    // Unknown languages don't validate.
    let spanishMnemonic = "pera campesina pelican"
    XCTAssertFalse(MnemonicUtil.validate(mnemonic: spanishMnemonic))

    // Mixed cases should be normalized.
    let mixedCaseMnemonic = "pear PEASANT PeLiCaN pen"
    XCTAssertTrue(MnemonicUtil.validate(mnemonic: mixedCaseMnemonic))

    // Mixed valid words and invalid words should be invalid.
    let mixedLanguageMnemonic = "pear peasant pelican pen 路 级 少 图"
    XCTAssertFalse(MnemonicUtil.validate(mnemonic: mixedLanguageMnemonic))

    // Whitespace padding shouldn't matter.
    let whitespacePaddedMnemonic = "    pear peasant pelican pen\t\t\n"
    XCTAssertTrue(MnemonicUtil.validate(mnemonic: whitespacePaddedMnemonic))
  }
}
