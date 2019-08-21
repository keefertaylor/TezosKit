// Copyright Keefer Taylor, 2019.

import Foundation

/// A policy that determines how to apply fees on an operation.
public enum OperationFeePolicy {
  /// Use the default fees provided by TezosKit.
  case `default`

  /// Use custom fees in the associated value.
  case custom(OperationFees)

  /// Estimate the fees.
  case estimate
}
