import XCTest
import TezosKit

class WalletTests: XCTestCase {
	private let mnemonic = "soccer click number muscle police corn couch bitter gorilla camp camera shove expire praise pill"
	private let passphrase = "TezosKitTest"

	// Expected outputs for a wallet without a passphrase.
	let expectedPublicKeyNoPassphrase = "edpku9ZF6UUAEo1AL3NWy1oxHLL6AfQcGYwA5hFKrEKVHMT3Xx889A"
	let expectedSecretKeyNoPassphrase = "edskS4pbuA7rwMjsZGmHU18aMP96VmjegxBzwMZs3DrcXHcMV7VyfQLkD5pqEE84wAMHzi8oVZF6wbgxv3FKzg7cLqzURjaXUp"
	let expectedPublicKeyHashNoPassphrase = "tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw"

	// Expected outputs for a wallet with a passphrase.
	let expectedPublicKeyPassphrase = "edpktnCgi3C7ZLyLrF4NAebDkgu5PZRRJ9BafxskVEj6U1GycyRird"
	let expectedSecretKeyPassphrase = "edskRjazzmroxmJagYDhCT1jXna8m9H2qvjtPAcrZYZ31og4ud1u2kkxYGv8e7CjmbW33QubzugueXqLFPMbM2eAj6j3AQHrCW"
	let expectedPublicKeyHashPassphrase = "tz1ZfhME1B2kmagqEJ9P7PE8joM3TbVQ5r4v"


	// Wallet generation with no parameters should never fail.
	public func testGenerateWallet() {
		let wallet = Wallet()
		XCTAssertNotNil(wallet)
		XCTAssertNotNil(wallet?.mnemonic)

		let walletWithPassphrase = Wallet(passphrase: passphrase)
		XCTAssertNotNil(walletWithPassphrase)
		XCTAssertNotNil(walletWithPassphrase?.mnemonic)
	}

	public func testGenerateWalletMnemonicNoPassphrase() {
		guard let wallet = Wallet(mnemonic: mnemonic) else {
			XCTFail()
			return
		}

		XCTAssertNotNil(wallet.mnemonic)
		XCTAssertEqual(wallet.mnemonic!, mnemonic)
		XCTAssertEqual(wallet.keys.publicKey, expectedPublicKeyNoPassphrase)
		XCTAssertEqual(wallet.keys.secretKey, expectedSecretKeyNoPassphrase)
		XCTAssertEqual(wallet.address, expectedPublicKeyHashNoPassphrase)
	}

	public func testGenerateWalletMnemonicEmptyPassphrase() {
		guard let wallet = Wallet(mnemonic: mnemonic, passphrase: "") else {
			XCTFail()
			return
		}

		// A wallet with an empty passphrase should be the same as a wallet with no passphrase.
		XCTAssertNotNil(wallet.mnemonic)
		XCTAssertEqual(wallet.mnemonic!, mnemonic)
		XCTAssertEqual(wallet.keys.publicKey, expectedPublicKeyNoPassphrase)
		XCTAssertEqual(wallet.keys.secretKey, expectedSecretKeyNoPassphrase)
		XCTAssertEqual(wallet.address, expectedPublicKeyHashNoPassphrase)
	}

	public func testGenerateWalletMnemonicWithPassphrase() {
		guard let wallet = Wallet(mnemonic: mnemonic, passphrase: passphrase) else {
			XCTFail()
			return
		}

		// A wallet with an empty passphrase should be the same as a wallet with no passphrase.
		XCTAssertNotNil(wallet.mnemonic)
		XCTAssertEqual(wallet.mnemonic!, mnemonic)
		XCTAssertEqual(wallet.keys.publicKey, expectedPublicKeyPassphrase)
		XCTAssertEqual(wallet.keys.secretKey, expectedSecretKeyPassphrase)
		XCTAssertEqual(wallet.address, expectedPublicKeyHashPassphrase)
	}

	public func testGenerateWalletFromSecretKey() {
		guard let wallet = Wallet(secretKey: expectedSecretKeyNoPassphrase) else {
			fatalError()
			return
		}

		XCTAssertNil(wallet.mnemonic)
		XCTAssertEqual(wallet.address, expectedPublicKeyHashNoPassphrase)
		XCTAssertEqual(wallet.keys.publicKey, expectedPublicKeyNoPassphrase)
		XCTAssertEqual(wallet.keys.secretKey, expectedSecretKeyNoPassphrase)

	}

	public func testGenerateWalletFromInvalidSecretKey() {
		let wallet = Wallet(secretKey: "thisIsNotAValidKey")
		XCTAssertNil(wallet)
	}
}
