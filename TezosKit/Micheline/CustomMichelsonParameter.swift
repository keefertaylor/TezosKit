// Copyright Keefer Taylor, 2019.

import Foundation

/// A custom Michelson paramater.
///
/// This abstract base class can be used to create Michelson parameters which TezosKit doesn't support.
public class CustomMichelsonParameter: MichelsonParameter {
  public let networkRepresentation: [String : Any]

  /// - Parameter networkRepresentation: A dictionary representation of the parameter which can be encoded to JSON.
  public init(networkRepresentation: [String: Any]) {
    self.networkRepresentation = networkRepresentation
  }
}
