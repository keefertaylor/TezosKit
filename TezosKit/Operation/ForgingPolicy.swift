// Copyright Keefer Taylor, 2019.

import Foundation

/// An enum defining policies used to forge operations.
public enum ForgingPolicy {
  /// Always forge operations remotely on the node.
  case remote

  /// Always forge locally. Fail if the operation cannot be forged locally.
  case local

  /// Attempt to forge locally but fallback to remote forging if local forging is not possible.
  case localWithRemoteFallBack
}
