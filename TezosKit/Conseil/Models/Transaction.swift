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
    public static let blockHash = "block_hash"
    public static let blockLevel = "block_level"
    public static let operationGroupHash = "operation_group_hash"
    public static let operationID = "operation_id"
    public static let parameters = "parameters"
  }

  public let source: Address
  public let destination: Address
  public let amount: Tez
  public let fee: Tez
  public let timestamp: TimeInterval
  public let blockHash: String
  public let blockLevel: Int
  public let operationGroupHash: String
  public let operationID: Int
  public let parameters: String?

  public init?(_ json: [String: Any]) {
    guard let source = json[Transaction.JSONKeys.source] as? String,
          let destination = json[Transaction.JSONKeys.destination] as? String,
          let rawAmount = json[Transaction.JSONKeys.amount] as? Int,
          let rawFee = json[Transaction.JSONKeys.fee] as? Int,
          let fee = Tez(String(describing: rawFee)),
          let amount = Tez(String(describing: rawAmount)),
          let timestamp = json[Transaction.JSONKeys.timestamp] as? TimeInterval,
          let blockHash = json[Transaction.JSONKeys.blockHash] as? String,
          let operationGroupHash = json[Transaction.JSONKeys.operationGroupHash] as? String,
          let operationID = json[Transaction.JSONKeys.operationID] as? Int,
          let blockLevel = json[Transaction.JSONKeys.blockLevel] as? Int else {
            return nil
    }

    self.init(
      source: source,
      destination:
      destination,
      amount: amount,
      fee: fee,
      timestamp: timestamp,
      blockHash: blockHash,
      blockLevel: blockLevel,
      operationGroupHash: operationGroupHash,
      operationID: operationID,
      parameters: json[Transaction.JSONKeys.parameters] as? String
    )
  }

  public init(
    source: Address,
    destination: Address,
    amount: Tez,
    fee: Tez,
    timestamp: TimeInterval,
    blockHash: String,
    blockLevel: Int,
    operationGroupHash: String,
    operationID: Int,
    parameters: String?
  ) {
    self.source = source
    self.destination = destination
    self.amount = amount
    self.fee = fee
    self.timestamp = timestamp
    self.blockHash = blockHash
    self.blockLevel = blockLevel
    self.operationGroupHash = operationGroupHash
    self.operationID = operationID
    self.parameters = parameters
  }
}
