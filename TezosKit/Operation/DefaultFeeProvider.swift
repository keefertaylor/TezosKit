// Copyright Keefer Taylor, 2019.

import Foundation

/// Provides default fees for operations.
public class DefaultFeeProvider {
  /// Returns default fees for the given protocol and operation.
  ///
  /// - Parameters:
  ///   - operationKind: The type of operation to request default fees for.
  ///   - tezosProtocol: The protocol to request default fees for. Default is Athens / Proto4.
  /// - Returns: Default fees for the requested inputs.
  public static func fees(
    for operationKind: OperationKind,
    in tezosProtocol: TezosProtocol = .athens
  ) -> OperationFees {
    switch tezosProtocol {
    case .athens:
      return feesInAthens(for: operationKind)
    }
  }

  /// Returns default fees for the athens protocol.
  private static func feesInAthens(for operationKind: OperationKind) -> OperationFees {
    switch operationKind {
    case .delegation:
      return OperationFees(
        fee: Tez(0.001_257),
        gasLimit: Tez(0.010_000),
        storageLimit: Tez.zeroBalance
      )
    case .origination:
      return OperationFees(
        fee: Tez(0.001_265),
        gasLimit: Tez(0.010_000),
        storageLimit: Tez(0.000_257)
      )
    case .reveal:
      return OperationFees(
        fee: Tez(0.001_268),
        gasLimit: Tez(0.010_000),
        storageLimit: Tez.zeroBalance
      )
    case .transaction:
      return OperationFees(
        fee: Tez(0.001_284),
        gasLimit: Tez(0.010_200),
        storageLimit: Tez(0.000_257)
      )
    }
  }
}
