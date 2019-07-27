// Copyright Keefer Taylor, 2019.

import Foundation

// A representation of a right parameter in micheline.
public struct MichelineRightParam: MichelineParam {
  public let json: [String: Any]

  // TODO: Refactor JSON.
  public init(arg: MichelineParam) {
    let argArray = [ arg.json ]
    self.json = [
      "prim": "right",
      "args": argArray
    ]
  }
}
