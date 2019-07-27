// Copyright Keefer Taylor, 2019.

import Foundation

// TODO: Support annots
// TODO: REmove contract deploy / code?
// TODO: Separate files?
// TODO: Comments

/// An abstract representation of a Micheline param.
///
/// See: https://tezos.gitlab.io/master/whitedoc/michelson.html
/// TODO: Rename `MichelineParam`
public protocol Micheline {
  var json: [String: Any] { get }
}

/// A string micheline param.
public struct MichelineString: Micheline {
  public let json: [String: Any]

  public init(string: String) {
    self.json = ["string": string]
  }
}

/// An int micheline param.
public struct MichelineInt: Micheline {
  public let json: [String: Any]

  public init(int: Int) {
    self.json = ["int": "\(int)"]
  }
}

public struct MichelinePair: Micheline {
  public let json: [String: Any]

  public init(left: Micheline, right: Micheline) {
    let argArray = [ left.json, right.json ]
    self.json = [
      "prim": "pair",
      "args": argArray
    ]
  }
}

public struct MichelineLeft: Micheline {
  public let json: [String: Any]

  // TODO: Refactor JSON.
  public init(arg: Micheline) {
    let argArray = [ arg.json ]
    self.json = [
      "prim": "left",
      "args": argArray
    ]
  }
}

public struct MichelineRight: Micheline {
  public let json: [String: Any]

  // TODO: Refactor JSON.
  public init(arg: Micheline) {
    let argArray = [ arg.json ]
    self.json = [
      "prim": "right",
      "args": argArray
    ]
  }
}

public struct MichelineUnit: Micheline {
  public let json: [String: Any] = [
    "prim": "unit"
  ]

  public init() {}
}

// TODO: Consider alternative constructors.
public struct MichelineBytes: Micheline {
  public let json: [String: Any]

  public init(hex: Hex) {
    json = [ "bytes": hex ]
  }
}

public struct MichelineBool: Micheline {
  public let json: [String: Any]

  public init(bool: Bool) {
    let stringRep = bool ? "true" : "false"
    json = [ "prim": stringRep ]
  }
}

public struct MichelineSome: Micheline {
  public let json: [String: Any]

  public init(some: Micheline) {
    json = [
      "prim": "some",
      "args": [
        some.json
      ]
    ]
  }
}

public struct MichelineNone: Micheline {
  public let json: [String: Any] = [ "prim": "none" ]

  public init() {}
}
