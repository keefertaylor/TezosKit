import XCTest
import TezosKit

class RevealOperationTest: XCTestCase {
	public func testDictionaryRepresentation() {
		let source = "tz1abc"
		let publicKey = "edpkXYZ"

		let operation = RevealOperation(from: source, publicKey: publicKey)
		let dictionary = operation.dictionaryRepresentation

		XCTAssertNotNil(dictionary["source"])
		XCTAssertEqual(dictionary["source"], source)

		XCTAssertNotNil(dictionary["public_key"])
		XCTAssertEqual(dictionary["public_key"], publicKey)
	}

	public func testDictionaryRepresentationFromWallet() {
		guard let wallet = Wallet() else {
			XCTFail()
			return
		}

		let operation = RevealOperation(from: wallet)
		let dictionary = operation.dictionaryRepresentation

		XCTAssertNotNil(dictionary["source"])
		XCTAssertEqual(dictionary["source"], wallet.address)

		XCTAssertNotNil(dictionary["public_key"])
		XCTAssertEqual(dictionary["public_key"], wallet.keys.publicKey)
	}

}
