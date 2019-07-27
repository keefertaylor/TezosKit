// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of a left parameter in micheline.
public struct MichelineLeftParam: MichelineParam {
  public let json: [String: Any]

  public init(arg: MichelineParam) {
    let argArray = [ arg.json ]
    self.json = [
      Micheline.primitive: Micheline.left,
      Micheline.args: argArray
    ]
  }
}
