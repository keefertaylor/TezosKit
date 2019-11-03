// Copyright Keefer Taylor, 2018

@testable import TezosKit
import XCTest

class WalletTests: XCTestCase {
  private let mnemonic =
    "soccer click number muscle police corn couch bitter gorilla camp camera shove expire praise pill"
  private let passphrase = "TezosKitTest"

  // Expected outputs for a wallet without a passphrase.
  let expectedPublicKeyNoPassphrase = "edpku9ZF6UUAEo1AL3NWy1oxHLL6AfQcGYwA5hFKrEKVHMT3Xx889A"
  let expectedSecretKeyNoPassphrase =
    "edskS4pbuA7rwMjsZGmHU18aMP96VmjegxBzwMZs3DrcXHcMV7VyfQLkD5pqEE84wAMHzi8oVZF6wbgxv3FKzg7cLqzURjaXUp"
  let expectedPublicKeyHashNoPassphrase = "tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw"

  // Expected outputs for a wallet with a passphrase.
  let expectedPublicKeyPassphrase = "edpktnCgi3C7ZLyLrF4NAebDkgu5PZRRJ9BafxskVEj6U1GycyRird"
  let expectedSecretKeyPassphrase =
    "edskRjazzmroxmJagYDhCT1jXna8m9H2qvjtPAcrZYZ31og4ud1u2kkxYGv8e7CjmbW33QubzugueXqLFPMbM2eAj6j3AQHrCW"
  let expectedPublicKeyHashPassphrase = "tz1ZfhME1B2kmagqEJ9P7PE8joM3TbVQ5r4v"

  // Wallet generation with no parameters should never fail.
  func testGenerateWallet() {
    let wallet = Wallet()
    XCTAssertNotNil(wallet)
    XCTAssertNotNil(wallet?.mnemonic)

    let walletWithPassphrase = Wallet(passphrase: passphrase)
    XCTAssertNotNil(walletWithPassphrase)
    XCTAssertNotNil(walletWithPassphrase?.mnemonic)
  }

  func testGenerateWalletMnemonicNoPassphrase() {
    guard let wallet = Wallet(mnemonic: mnemonic) else {
      XCTFail()
      return
    }

    XCTAssertNotNil(wallet.mnemonic)
    XCTAssertEqual(wallet.mnemonic!, mnemonic)
    XCTAssertEqual(wallet.publicKey.base58CheckRepresentation, expectedPublicKeyNoPassphrase)
    XCTAssertEqual(wallet.secretKey.base58CheckRepresentation, expectedSecretKeyNoPassphrase)
    XCTAssertEqual(wallet.address, expectedPublicKeyHashNoPassphrase)
  }

  func testGenerateWalletMnemonicEmptyPassphrase() {
    guard let wallet = Wallet(mnemonic: mnemonic, passphrase: "") else {
      XCTFail()
      return
    }

    // A wallet with an empty passphrase should be the same as a wallet with no passphrase.
    XCTAssertNotNil(wallet.mnemonic)
    XCTAssertEqual(wallet.mnemonic!, mnemonic)
    XCTAssertEqual(wallet.publicKey.base58CheckRepresentation, expectedPublicKeyNoPassphrase)
    XCTAssertEqual(wallet.secretKey.base58CheckRepresentation, expectedSecretKeyNoPassphrase)
    XCTAssertEqual(wallet.address, expectedPublicKeyHashNoPassphrase)
  }

  func testGenerateWalletMnemonicWithPassphrase() {
    guard let wallet = Wallet(mnemonic: mnemonic, passphrase: passphrase) else {
      XCTFail()
      return
    }

    // A wallet with an empty passphrase should be the same as a wallet with no passphrase.
    XCTAssertNotNil(wallet.mnemonic)
    XCTAssertEqual(wallet.mnemonic!, mnemonic)
    XCTAssertEqual(wallet.publicKey.base58CheckRepresentation, expectedPublicKeyPassphrase)
    XCTAssertEqual(wallet.secretKey.base58CheckRepresentation, expectedSecretKeyPassphrase)
    XCTAssertEqual(wallet.address, expectedPublicKeyHashPassphrase)
  }

  func testGenerateWalletFromSecretKey() {
    guard let wallet = Wallet(secretKey: expectedSecretKeyNoPassphrase) else {
      XCTFail()
      return
    }

    XCTAssertNil(wallet.mnemonic)
    XCTAssertEqual(wallet.address, expectedPublicKeyHashNoPassphrase)
    XCTAssertEqual(wallet.publicKey.base58CheckRepresentation, expectedPublicKeyNoPassphrase)
    XCTAssertEqual(wallet.secretKey.base58CheckRepresentation, expectedSecretKeyNoPassphrase)
  }

  func testGenerateWalletFromInvalidSecretKey() {
    let wallet = Wallet(secretKey: "thisIsNotAValidKey")
    XCTAssertNil(wallet)
  }

  func testEqualityFromMnemonicAndPassphrase() {
    // Wallet 1 and wallet 2
    guard let wallet1 = Wallet(mnemonic: mnemonic, passphrase: passphrase),
      let wallet2 = Wallet(mnemonic: mnemonic, passphrase: passphrase) else {
      XCTFail()
      return
    }
    XCTAssertEqual(wallet1, wallet2)

    // Wallet 3 is the same as wallet 1 but with a different mnemonic.
    guard let wallet3 = Wallet(mnemonic: "pear pear pear pear pear pear pear", passphrase: passphrase) else {
      XCTFail()
      return
    }
    XCTAssertNotEqual(wallet1, wallet3)

    // Wallet 4 is the same as wallet 1 but with a different passphrase.
    guard let wallet4 = Wallet(mnemonic: mnemonic, passphrase: "TezosKit2") else {
      XCTFail()
      return
    }
    XCTAssertNotEqual(wallet1, wallet4)

    // Wallet 5 is different from wallet 1 by both its mnemonic and passphrase.
    guard let wallet5 = Wallet(mnemonic: "pear pear pear pear", passphrase: "TezosKit2") else {
      XCTFail()
      return
    }
    XCTAssertNotEqual(wallet1, wallet5)
  }

  func testEqualityFromSecretKeys() {
    // Test equality on wallets generated from a secret key.
    let secretKey1 =
      "edskS4pbuA7rwMjsZGmHU18aMP96VmjegxBzwMZs3DrcXHcMV7VyfQLkD5pqEE84wAMHzi8oVZF6wbgxv3FKzg7cLqzURjaXUp"
    let secretKey2 =
      "edskRr4SG9qd4Hx9jZvdQ5dS2bCKxUnaEnXv9BrwSs2YxU8g8WpQ2CfXuiE96BWSsceaSi6HvSz4YnTKkwVqeWpUF288SzLXZ5"
    guard let wallet1 = Wallet(secretKey: secretKey1),
      let wallet2 = Wallet(secretKey: secretKey1),
      let wallet3 = Wallet(secretKey: secretKey2) else {
      XCTFail()
      return
    }
    // Wallets 1 and 2 were generated from the same secret key, wallet 3 was not.
    XCTAssertEqual(wallet1, wallet2)
    XCTAssertNotEqual(wallet1, wallet3)
  }

  func testSign() {
    let hexToSign = "deadbeef"
    guard
      let wallet = Wallet(mnemonic: mnemonic),
      let signature = wallet.sign(hexToSign)
    else {
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
}
