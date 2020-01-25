// Copyright Keefer Taylor, 2020

import Foundation

/// A payload that can be used to pack data.
public struct PackDataPayload {
  // JSON keys and values
  private enum JSON {
    public enum Keys {
      public static let data = "data"
      public static let gas = "gas"
      public static let prim = "prim"
      public static let type = "type"
    }
    public enum Values {
      public static let gasAmount = "8000"
    }
  }

  // Data to place in the payload.
  private let michelsonParameter: MichelsonParameter
  private let michelsonComparable: MichelsonComparable

  /// Retrieve a dictionary representation of the payload.
  public var dictionaryRepresentation: [String: Any] {
    let dictionary: [String: Any] = [
      JSON.Keys.gas: JSON.Values.gasAmount,
      JSON.Keys.data: michelsonParameter.networkRepresentation,
      JSON.Keys.type: MichelsonComparable.networkRepresentation(for: michelsonComparable)
    ]
    return dictionary
  }

  /// Creates a pack data payload with the given inputs.
  ///
  /// - Parameters:
  ///   - michelsonParameter: The parameter to pack.
  ///   - michelsonComparable: The type of the parameter.
  public init(
    michelsonParameter: MichelsonParameter,
    michelsonComparable: MichelsonComparable
  ) {
    self.michelsonParameter = michelsonParameter
    self.michelsonComparable = michelsonComparable
  }
}
