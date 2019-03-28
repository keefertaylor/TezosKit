// Copyright Keefer Taylor, 2019

import TezosKit
import XCTest

class TransactionsResponseAdapterTest: XCTestCase {
  func testParse() {
    let source = "tz1abc"
    let destination = "tz1xyz"
    let amount = Tez(10.0)
    let fee = Tez(1)
    let timestamp: TimeInterval = 1_234_567

    let validTransaction: [String: Any] = [
      Transaction.JSONKeys.source: source,
      Transaction.JSONKeys.destination: destination,
      Transaction.JSONKeys.amount: Double(amount.humanReadableRepresentation)!,
      Transaction.JSONKeys.fee: Double(fee.humanReadableRepresentation)!,
      Transaction.JSONKeys.timestamp: timestamp
    ]

    let transactionWithMissingField: [String: Any] = [
      Transaction.JSONKeys.source: source,
      Transaction.JSONKeys.destination: destination,
      Transaction.JSONKeys.amount: Double(amount.humanReadableRepresentation)!,
      Transaction.JSONKeys.timestamp: timestamp
    ]

    let badInput: [String: Any] = [
      "publicKey": "edpk123xyz",
      "kind": "reveal"
    ]

    let transactions = [ validTransaction, transactionWithMissingField, badInput ]
    let data = JSONUtils.jsonString(for: transactions)?.data(using: .utf8)

    let parsedTransactions = TransactionsResponseAdapter.parse(input: data!)!
    XCTAssertEqual(parsedTransactions.count, 1)
    XCTAssertEqual(parsedTransactions[0].source, source)
    XCTAssertEqual(parsedTransactions[0].destination, destination)
    XCTAssertEqual(parsedTransactions[0].amount, amount)
    XCTAssertEqual(parsedTransactions[0].fee, fee)
    XCTAssertEqual(parsedTransactions[0].timestamp, timestamp)
  }
}
