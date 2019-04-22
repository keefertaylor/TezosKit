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
    let blockHash = "BMc3kxPnn95TxYKVPehmYWXuaoKBneoPKeDk4sz7usFp7Aumnez"
    let blockLevel = 323_100
    let operationGroupHash = "opMiJzXJV8nKWy7VTLh2yxFL8yUGDpVkvnbA5hUwj9dSnpMEEMa"
    let operationID = 1_511_646

    let validTransaction: [String: Any] = [
      Transaction.JSONKeys.source: source,
      Transaction.JSONKeys.destination: destination,
      Transaction.JSONKeys.amount: Double(amount.rpcRepresentation)!,
      Transaction.JSONKeys.fee: Double(fee.rpcRepresentation)!,
      Transaction.JSONKeys.timestamp: timestamp,
      Transaction.JSONKeys.blockHash: blockHash,
      Transaction.JSONKeys.blockLevel: blockLevel,
      Transaction.JSONKeys.operationGroupHash: operationGroupHash,
      Transaction.JSONKeys.operationID: operationID
    ]

    let transactionWithMissingField: [String: Any] = [
      Transaction.JSONKeys.source: source,
      Transaction.JSONKeys.destination: destination,
      Transaction.JSONKeys.amount: Double(amount.rpcRepresentation)!,
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
