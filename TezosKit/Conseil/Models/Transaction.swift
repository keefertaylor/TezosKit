// Copyright Keefer Taylor, 2019

import Foundation

/// A transaction retrieved from Conseil.
public struct Transaction {
  public enum JSONKeys {
    public static let source = "source"
    public static let destination = "destination"
    public static let delegate = "delegate"
    public static let amount = "amount"
    public static let fee = "fee"
    public static let timestamp = "timestamp"
    public static let blockHash = "block_hash"
    public static let blockLevel = "block_level"
    public static let operationGroupHash = "operation_group_hash"
    public static let operationID = "operation_id"
    public static let parameters = "parameters"
    public static let parametersMicheline = "parameters_micheline"
    public static let parametersEntrypoints = "parameters_entrypoints"
    public static let kind = "kind"
    public static let status = "status"
  }

  public let source: Address
  public let destination: Address? // Destination is null in the case of transactions like delegation
  // swiftlint:disable:next weak_delegate
  public let delegate: Address?
  public let amount: Tez
  public let fee: Tez?
  public let timestamp: TimeInterval
  public let blockHash: String
  public let blockLevel: Int
  public let operationGroupHash: String
  public let operationID: Int
  public let parameters: String?
  public let parametersMicheline: String?
  public let parametersEntrypoints: String?
  public let kind: String // TODO: convert to enum
  public let status: String // TODO: convert to enum

  public init?(_ json: [String: Any]) {
    guard let source = json[Transaction.JSONKeys.source] as? String,
          let timestamp = json[Transaction.JSONKeys.timestamp] as? TimeInterval,
          let blockHash = json[Transaction.JSONKeys.blockHash] as? String,
          let operationGroupHash = json[Transaction.JSONKeys.operationGroupHash] as? String,
          let operationID = json[Transaction.JSONKeys.operationID] as? Int,
          let blockLevel = json[Transaction.JSONKeys.blockLevel] as? Int,
          let kind = json[Transaction.JSONKeys.kind] as? String,
          let status = json[Transaction.JSONKeys.status] as? String else {
            return nil
    }

	let rawFee = json[Transaction.JSONKeys.fee] as? Int
	let fee = Tez(String(describing: rawFee ?? 0))
    let rawAmount = json[Transaction.JSONKeys.amount] as? Int
    let amount = Tez(String(describing: rawAmount ?? 0))

    self.init(
      source: source,
      destination: json[Transaction.JSONKeys.destination] as? String,
      delegate: json[Transaction.JSONKeys.delegate] as? String,
      amount: amount ?? Tez.zeroBalance,
      fee: fee,
      timestamp: timestamp,
      blockHash: blockHash,
      blockLevel: blockLevel,
      operationGroupHash: operationGroupHash,
      operationID: operationID,
      parameters: json[Transaction.JSONKeys.parameters] as? String,
      parametersMicheline: json[Transaction.JSONKeys.parametersMicheline] as? String,
      parametersEntrypoints: json[Transaction.JSONKeys.parametersEntrypoints] as? String,
      kind: kind,
      status: status
    )
  }

  public init(
    source: Address,
    destination: Address?,
    delegate: Address?,
    amount: Tez,
    fee: Tez?,
    timestamp: TimeInterval,
    blockHash: String,
    blockLevel: Int,
    operationGroupHash: String,
    operationID: Int,
    parameters: String?,
    parametersMicheline: String?,
    parametersEntrypoints: String?,
    kind: String,
    status: String
  ) {
    self.source = source
    self.destination = destination
    self.delegate = delegate
    self.amount = amount
    self.fee = fee
    self.timestamp = timestamp
    self.blockHash = blockHash
    self.blockLevel = blockLevel
    self.operationGroupHash = operationGroupHash
    self.operationID = operationID
    self.parameters = parameters
    self.parametersMicheline = parametersMicheline
    self.parametersEntrypoints = parametersEntrypoints
    self.kind = kind
    self.status = status
  }
}
