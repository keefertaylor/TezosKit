// Copyright Keefer Taylor, 2019.

import Foundation

// A representation of a some parameter in micheline.
public struct MichelineSomeParam: MichelineParam {
  public let networkRepresentation: [String: Any]

  public init(some: MichelineParam) {
    self.networkRepresentation = [
      MichelineConstants.primitive: MichelineConstants.some,
      MichelineConstants.args: [
        some.networkRepresentation
      ]
    ]
  }
}
