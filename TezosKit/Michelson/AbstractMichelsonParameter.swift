// Copyright Keefer Taylor, 2019.

import Foundation

/// Models a swift dictionary as a JSON representation (Micheline) of a Michelson parameter.
///
/// This abstract base class can be used to create Michelson parameters which TezosKit doesn't support.
public class AbstractMichelsonParameter: MichelsonParameter {
  public let networkRepresentation: [String: Any]

  /// - Parameter networkRepresentation: A dictionary representation of the parameter which can be encoded to JSON.
  public init(networkRepresentation: [String: Any]) {
    self.networkRepresentation = networkRepresentation
  }
}
