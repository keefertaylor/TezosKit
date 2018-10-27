import XCTest
import TezosKit

class TransactionOperationTest: XCTestCase {
	let destination = "tz1def"
	let balance = TezosBalance(balance: 3.50)

	public func testTransation() {
		let source = "tz1abc"

		let operation = TransactionOperation(amount: balance, source: source, destination: destination)
		let dictionary = operation.dictionaryRepresentation

		XCTAssertNotNil(dictionary["source"])
		XCTAssertEqual(dictionary["source"], source)

		XCTAssertNotNil(dictionary["destination"])
		XCTAssertEqual(dictionary["destination"], destination)

		XCTAssertNotNil(dictionary["amount"])
		XCTAssertEqual(dictionary["amount"], balance.rpcRepresentation)
	}

	public func testTransationFromWallet() {
		guard let wallet = Wallet() else {
			XCTFail()
			return
		}

		let operation = TransactionOperation(amount: balance, source: wallet, destination: destination)
		let dictionary = operation.dictionaryRepresentation

		XCTAssertNotNil(dictionary["source"])
		XCTAssertEqual(dictionary["source"], wallet.address)

		XCTAssertNotNil(dictionary["destination"])
		XCTAssertEqual(dictionary["destination"], destination)

		XCTAssertNotNil(dictionary["amount"])
		XCTAssertEqual(dictionary["amount"], balance.rpcRepresentation)
	}


}
