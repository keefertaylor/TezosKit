// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of a left parameter in micheline.
public struct MichelineLeftParam: MichelineParam {
  public let json: [String: Any]

  // TODO: Refactor JSON.
  public init(arg: MichelineParam) {
    let argArray = [ arg.json ]
    self.json = [
      "prim": "left",
      "args": argArray
    ]
  }
}
