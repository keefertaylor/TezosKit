// Copyright Keefer Taylor, 2019.

import Foundation

/// A comparable Michelson type.
public enum MichelsonComparable: String {
  case address
  case bool
  case bytes
  case int
  case keyHash = "key_hash"
  case mutez
  case nat
  case string
  case timestamp
}
