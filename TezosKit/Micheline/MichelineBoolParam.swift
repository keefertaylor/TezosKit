// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of a boolean parameter in micheline.
public struct MichelineBoolParam: MichelineParam {
  public let networkRepresentation: [String: Any]

  public init(bool: Bool) {
    let stringRep = bool ? MichelineConstants.true : MichelineConstants.false
    self.networkRepresentation = [ MichelineConstants.primitive: stringRep ]
  }
}
