// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of an unit parameter in micheline.
public struct MichelineUnitParam: MichelineParam {
  public let networkRepresentation: [String: Any]

  public init() {
    self.networkRepresentation = [ MichelineConstants.primitive: MichelineConstants.unit ]
  }
}
