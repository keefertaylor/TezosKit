// Copyright Keefer Taylor, 2019.

import Foundation

/// A custom micheline paramater.
///
/// This parameter can be used to create micheline parameters which TezosKit doesn't support.
// TODO: Should this be a super class?
// TODO: Codable
// TODO: Naming
public struct CustomMichelineParam: MichelineParam {
  public let networkRepresentation: [String : Any]

  /// - Parameter networkRepresentation: A dictionary representation of the parameter which can be encoded to JSON.
  public init(networkRepresentation: [String: Any]) {
    self.networkRepresentation = networkRepresentation
  }
}
