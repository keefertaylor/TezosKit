// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of an integer parameter in micheline.
public struct MichelineIntParam: MichelineParam {
  public let networkRepresentation: [String: Any]

  public init(int: Int) {
    self.networkRepresentation = [MichelineConstants.int: "\(int)"]
  }
}
