// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of a string parameter in micheline.
public struct MichelineStringParam: MichelineParam {
  public let networkRepresentation: [String: Any]

  public init(string: String) {
    self.networkRepresentation = [MichelineConstants.string: string]
  }
}
