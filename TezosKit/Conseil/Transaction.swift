// Copyright Keefer Taylor, 2019

import Foundation

/// A transaction retrieved from Conseil.
public struct Transaction {
  public enum JSONKeys {
    public static let source = "source"
    public static let destination = "destination"
    public static let amount = "amount"
    public static let fee = "fee"
    public static let timestamp = "timestamp"
  }

  public let source: String
  public let destination: String
  public let amount: Tez
  public let fee: Tez
  public let timestamp: TimeInterval

  public init?(_ json: [String: Any]) {
    guard let source = json[Transaction.JSONKeys.source] as? String,
          let destination = json[Transaction.JSONKeys.destination] as? String,
          let rawAmount = json[Transaction.JSONKeys.amount] as? Int,
          let rawFee = json[Transaction.JSONKeys.fee] as? Int,
          let fee = Tez(String(describing: rawFee)),
          let amount = Tez(String(describing: rawAmount)),
          let timestamp = json[Transaction.JSONKeys.timestamp] as? TimeInterval else {
            return nil
    }

    self.init(
      source: source,
      destination:
      destination,
      amount: amount,
      fee: fee,
      timestamp: timestamp
    )
  }

  public init(source: String, destination: String, amount: Tez, fee: Tez, timestamp: TimeInterval) {
    self.source = source
    self.destination = destination
    self.amount = amount
    self.fee = fee
    self.timestamp = timestamp
  }
}
