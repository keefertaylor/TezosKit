// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of a left parameter in micheline.
public struct MichelineLeftParam: MichelineParam {
  public let networkRepresentation: [String: Any]

  public init(arg: MichelineParam) {
    let argArray = [ arg.networkRepresentation ]
    self.networkRepresentation = [
      MichelineConstants.primitive: MichelineConstants.left,
      MichelineConstants.args: argArray
    ]
  }
}
