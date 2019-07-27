// Copyright Keefer Taylor, 2019.

import Foundation

// A representation of a right parameter in micheline.
public struct MichelineRightParam: MichelineParam {
  public let json: [String: Any]

  public init(arg: MichelineParam) {
    let argArray = [ arg.json ]
    self.json = [
      Micheline.primitive: Micheline.right,
      Micheline.args: argArray
    ]
  }
}
