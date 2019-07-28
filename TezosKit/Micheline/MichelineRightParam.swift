// Copyright Keefer Taylor, 2019.

import Foundation

// A representation of a right parameter in micheline.
public struct MichelineRightParam: MichelineParam {
  public let networkRepresentation: [String: Any]

  public init(arg: MichelineParam) {
    let argArray = [ arg.networkRepresentation ]
    self.networkRepresentation = [
      MichelineConstants.primitive: MichelineConstants.right,
      MichelineConstants.args: argArray
    ]
  }
}
