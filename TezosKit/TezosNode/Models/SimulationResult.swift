// Copyright Keefer Taylor, 2019.

import Foundation

/// The result of simulating an operation.
public enum SimulationResult {
  /// The simulation failed.
  case failure

  /// The simulation succeeded, with the given gas and storage consumed.
  case success(consumedGas: Int, consumedStorage: Int)
}
