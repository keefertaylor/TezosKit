// Copyright Keefer Taylor, 2019.

import Foundation

/// Provides default fees for operations.
public class DefaultFeeProvider {
  /// Returns default fees for the given protocol and operation.
  ///
  /// - Parameters:
  ///   - operationKind: The type of operation to request default fees for.
  ///   - tezosProtocol: The protocol to request default fees for. Default is Carthage / Proto6.
  /// - Returns: Default fees for the requested inputs.
  public static func fees(
    for operationKind: OperationKind,
    in tezosProtocol: TezosProtocol = .carthage
  ) -> OperationFees {
    switch tezosProtocol {
    case .athens:
      return feesInAthens(for: operationKind)
    case .babylon:
      return feesInBabylon(for: operationKind)
    case .carthage:
      return feesInCarthage(for: operationKind)

    }
  }

  /// Returns default fees for the athens protocol.
  private static func feesInAthens(for operationKind: OperationKind) -> OperationFees {
    switch operationKind {
    case .delegation:
      return OperationFees(
        fee: Tez(0.001_257),
        gasLimit: 10_000,
        storageLimit: 0
      )
    case .reveal:
      return OperationFees(
        fee: Tez(0.001_268),
        gasLimit: 10_000,
        storageLimit: 0
      )
    case .transaction:
      return OperationFees(
        fee: Tez(0.001_284),
        gasLimit: 10_200,
        storageLimit: 257
      )
	// TODO(keefertaylor): Something more sane here
    case .origination:
      return OperationFees(
        fee: Tez(0.001_284),
        gasLimit: 10_200,
        storageLimit: 257
      )
    }
  }

  /// Returns default fees for the babylon protocol.
  private static func feesInBabylon(for operationKind: OperationKind) -> OperationFees {
    switch operationKind {
    case .delegation:
      return OperationFees(
        fee: Tez(0.001_257),
        gasLimit: 10_000,
        storageLimit: 0
      )
    case .reveal:
      return OperationFees(
        fee: Tez(0.001_268),
        gasLimit: 10_000,
        storageLimit: 0
      )
    case .transaction:
      return OperationFees(
        fee: Tez(0.001_284),
        gasLimit: 10_307,
        storageLimit: 257
      )
    // TODO(keefertaylor): Something more sane here
    case .origination:
      return OperationFees(
        fee: Tez(0.001_284),
        gasLimit: 10_200,
        storageLimit: 257
      )
    }
  }

  /// Returns default fees for the Carthage protocol.
  private static func feesInCarthage(for operationKind: OperationKind) -> OperationFees {
    switch operationKind {
    case .delegation:
      return OperationFees(
        fee: Tez(0.001_257),
        gasLimit: 10_000,
        storageLimit: 0
      )
    case .reveal:
      return OperationFees(
        fee: Tez(0.001_268),
        gasLimit: 10_000,
        storageLimit: 0
      )
    case .transaction:
      return OperationFees(
        fee: Tez(0.001_284),
        gasLimit: 10_307,
        storageLimit: 257
      )
    // TODO(keefertaylor): Something more sane here
    case .origination:
      return OperationFees(
        fee: Tez(0.001_284),
        gasLimit: 10_307,
        storageLimit: 257
      )
    }
  }
}
