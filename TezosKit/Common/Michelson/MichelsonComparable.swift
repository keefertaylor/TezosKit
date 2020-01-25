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

  private enum JSON {
    public enum Keys {
      public static let prim = "prim"
    }
  }

  public static func networkRepresentation(for type: MichelsonComparable) -> [String: String] {
    return [ JSON.Keys.prim: type.rawValue ]
  }
}
