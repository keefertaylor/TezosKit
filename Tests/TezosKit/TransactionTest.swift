// Copyright Keefer Taylor, 2019

import TezosKit
import XCTest

final class TransactionTest: XCTestCase {
  func testValidTransaction() {
    let source = "tz1abc"
    let destination = "tz1xyz"
    let amount = Tez(10.0)
    let fee = Tez(1)
    let timestamp: TimeInterval = 1_234_567

    let jsonDict: [String: Any] = [
      Transaction.JSONKeys.source: source,
      Transaction.JSONKeys.destination: destination,
      Transaction.JSONKeys.amount: Double(amount.humanReadableRepresentation)!,
      Transaction.JSONKeys.fee: Double(fee.humanReadableRepresentation)!,
      Transaction.JSONKeys.timestamp: timestamp
    ]

    guard let transaction = Transaction(jsonDict) else {
      XCTFail()
      return
    }

    XCTAssertEqual(transaction.source, source)
    XCTAssertEqual(transaction.destination, destination)
    XCTAssertEqual(transaction.amount, amount)
    XCTAssertEqual(transaction.fee, fee)
    XCTAssertEqual(transaction.timestamp, timestamp)
  }

  func testInValidTransaction_missingFee() {
    let source = "tz1abc"
    let destination = "tz1xyz"
    let amount = Tez(10.0)
    let timestamp: TimeInterval = 1_234_567

    let jsonDict: [String: Any] = [
      Transaction.JSONKeys.source: source,
      Transaction.JSONKeys.destination: destination,
      Transaction.JSONKeys.amount: Double(amount.humanReadableRepresentation)!,
      Transaction.JSONKeys.timestamp: timestamp
    ]

    XCTAssertNil(Transaction(jsonDict))
  }

  func testInValidTransaction_badInput() {
    let source = "tz1abc"
    let destination = "tz1xyz"
    let amount = Tez(10.0)
    let timestamp: TimeInterval = 1_234_567

    let jsonDict: [String: Any] = [
      "publicKey": "edpk123xyz",
      "kind": "reveal"
    ]

    XCTAssertNil(Transaction(jsonDict))
  }
}
