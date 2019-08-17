// Copyright Keefer Taylor, 2019.

import Foundation

public enum SimulationResult {
  case failure
  case success(consumedGas: Int, consumedStorage: Int)
}
