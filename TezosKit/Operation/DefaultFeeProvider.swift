// Copyright Keefer Taylor, 2019.

import Foundation

/// Provides default fees for operations.
public class DefaultFeeProvider {
  /// Provide default fees for the given protocol.
  ///
  /// - Parameters:
  ///   - operationKind: The type of operation to request default fees for.
  ///   - tezosProtocol: The protocol to request default fees for. Default is Athens / Proto4.
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
      let fee = Tez(0.001_257)
      let storageLimit = Tez.zeroBalance
      let gasLimit = Tez(0.010_000)
      return OperationFees(fee: fee, gasLimit: gasLimit, storageLimit: storageLimit)
    case .origination:
      let fee = Tez(0.001_265)
      let storageLimit = Tez(0.000_257)
      let gasLimit = Tez(0.010_000)
      return OperationFees(fee: fee, gasLimit: gasLimit, storageLimit: storageLimit)
    case .reveal:
      let fee = Tez(0.001_268)
      let storageLimit = Tez.zeroBalance
      let gasLimit = Tez(0.010_000)
      return OperationFees(fee: fee, gasLimit: gasLimit, storageLimit: storageLimit)
    case .transaction:
      let fee = Tez(0.001_284)
      let storageLimit = Tez(0.000_257)
      let gasLimit = Tez(0.010_200)
      return OperationFees(fee: fee, gasLimit: gasLimit, storageLimit: storageLimit)
    }
  }
}
