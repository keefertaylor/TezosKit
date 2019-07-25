// Copyright Keefer Taylor, 2019.

import Foundation

/// An abstract representation of a Micheline param.
///
/// See: https://tezos.gitlab.io/master/whitedoc/michelson.html
public protocol Micheline {
  var json: [String: String] { get }
}

/// A string micheline param.
public struct MichelineString: Micheline {
  public let json: [String: String]

  public init(string: String) {
    self.json = ["string": string]
  }
}

/// An int micheline param.
public struct MichelineInt: Micheline {
  public let json: [String: String]

  public init(int: Int) {
    self.json = ["int": "\(int)"]
  }
}
