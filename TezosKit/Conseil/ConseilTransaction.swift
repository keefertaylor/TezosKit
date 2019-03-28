// Copyright Keefer Taylor, 2019

import Foundation

/// A transaction retrieved from Conseil.
public struct ConseilTransaction {
  public let source: String
  public let destination: String
  public let amount: Tez
  public let fee: Tez
  public let timestamp: TimeInterval

  public init?(_ json: [String: Any]) {
    guard let source = json["source"] as? String,
          let destination = json["destination"] as? String,
          let amount = json["amount"] as? Double,
          let fee = json["fee"] as? Double,
          let timestamp = json["timestamp"] as? TimeInterval else {
            return nil
    }
    self.init(source: source, destination: destination, amount: Tez(amount), fee: Tez(fee), timestamp: timestamp)
  }

  public init(source: String, destination: String, amount: Tez, fee: Tez, timestamp: TimeInterval) {
    self.source = source
    self.destination = destination
    self.amount = amount
    self.fee = fee
    self.timestamp = timestamp
  }
}
