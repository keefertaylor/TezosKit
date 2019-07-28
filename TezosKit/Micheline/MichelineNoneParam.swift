// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of a none param in Micheline.
public struct MichelineNoneParam: MichelineParam {
  public let networkRepresentation: [String: Any]

  public init() {
    self.networkRepresentation = [ MichelineConstants.primitive: MichelineConstants.none ]
  }
}
