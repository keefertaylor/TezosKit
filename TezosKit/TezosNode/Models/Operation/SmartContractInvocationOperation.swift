// Copyright Keefer Taylor, 2020

import Foundation

/// An operation to invoke a smart contract.
public class SmartContractInvocationOperation: TransactionOperation {
  internal enum JSON {
    public enum Keys {
      public static let entrypoint = "entrypoint"
      public static let parameters = "parameters"
      public static let value = "value"
    }
    public enum Values {
      public static let `default` = "default"
    }
  }

  private let entrypoint: String?
  private let parameter: MichelsonParameter?

  public override var dictionaryRepresentation: [String: Any] {
    var operation = super.dictionaryRepresentation

    let parameter = self.parameter ?? UnitMichelsonParameter()
    let entrypoint = self.entrypoint ?? SmartContractInvocationOperation.JSON.Values.default

    let parameters: [String: Any] = [
      SmartContractInvocationOperation.JSON.Keys.entrypoint: entrypoint,
      SmartContractInvocationOperation.JSON.Keys.value: parameter.networkRepresentation
    ]
    operation[SmartContractInvocationOperation.JSON.Keys.parameters] = parameters

    return operation
  }

  /// - Parameters:
  ///   - amount: The amount of XTZ to transact.
  ///   - entrypoint: An optional entrypoint to use for the transaction. If nil, the default entry point is used.
  ///   - parameter: An optional parameter to include in the transaction if the call is being made to a smart contract. If nil, the unit parameter is used.
  ///   - from: The address that is sending the XTZ.
  ///   - to: The address that is receiving the XTZ.
  ///   - operationFees: OperationFees for the transaction.
  public init(
    amount: Tez,
    entrypoint: String? = nil,
    parameter: MichelsonParameter? = nil,
    source: Address,
    destination: Address,
    operationFees: OperationFees
  ) {
    self.entrypoint = entrypoint
    self.parameter = parameter

    super.init(amount: amount, source: source, destination: destination, operationFees: operationFees)
  }

  public override func mutableCopy(with zone: NSZone? = nil) -> Any {
    return SmartContractInvocationOperation(
      amount: amount,
      entrypoint: entrypoint,
      parameter: parameter,
      source: source,
      destination: destination,
      operationFees: operationFees
    )
  }
}
