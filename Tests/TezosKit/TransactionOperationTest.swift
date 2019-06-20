// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class TransactionOperationTest: XCTestCase {
  let destination = "tz1def"
  let balance = Tez(3.50)

  public func testTransation() {
    let source = "tz1abc"

    let operation = OperationFactory.testFactory.transactionOperation(
      amount: balance,
      source: source,
      destination: destination
    )
    let dictionary = operation.dictionaryRepresentation

    XCTAssertNotNil(dictionary["source"])
    XCTAssertEqual(dictionary["source"] as? String, source)

    XCTAssertNotNil(dictionary["destination"])
    XCTAssertEqual(dictionary["destination"] as? String, destination)

    XCTAssertNotNil(dictionary["amount"])
    XCTAssertEqual(dictionary["amount"] as? String, balance.rpcRepresentation)
  }
}
