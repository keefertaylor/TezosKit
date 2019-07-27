// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of an integer parameter in micheline.
public struct MichelineIntParam: MichelineParam {
  public let json: [String: Any]

  public init(int: Int) {
    self.json = ["int": "\(int)"]
  }
}
