// Copyright Keefer Taylor, 2019.

import Foundation

/// A policy to apply when deciding what gas limit to use.
public enum GasLimitPolicy {
  case estimate
  case `default`
  case custom(Int)
}
