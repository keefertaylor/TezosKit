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
    let blockHash = "BMc3kxPnn95TxYKVPehmYWXuaoKBneoPKeDk4sz7usFp7Aumnez"
    let blockLevel = 323_100
    let operationGroupHash = "opMiJzXJV8nKWy7VTLh2yxFL8yUGDpVkvnbA5hUwj9dSnpMEEMa"
    let operationID = 1_511_646

    let jsonDict: [String: Any] = [
      Transaction.JSONKeys.source: source,
      Transaction.JSONKeys.destination: destination,
      Transaction.JSONKeys.amount: Int(amount.rpcRepresentation)!,
      Transaction.JSONKeys.fee: Int(fee.rpcRepresentation)!,
      Transaction.JSONKeys.timestamp: timestamp,
      Transaction.JSONKeys.blockHash: blockHash,
      Transaction.JSONKeys.blockLevel: blockLevel,
      Transaction.JSONKeys.operationGroupHash: operationGroupHash,
      Transaction.JSONKeys.operationID: operationID
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
    let jsonDict: [String: Any] = [
      "publicKey": "edpk123xyz",
      "kind": "reveal"
    ]

    XCTAssertNil(Transaction(jsonDict))
  }
}
