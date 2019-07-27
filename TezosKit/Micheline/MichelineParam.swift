// Copyright Keefer Taylor, 2019.

import Foundation

// Things to do:
// - Remove contract deploy code (or write an integration test)
// - Support annotations (or document that TezosKit doesn't)

/// String constants used in Micheline param JSON encoding.
internal enum Micheline {
  public static let args = "args"
  public static let bytes = "bytes"
  public static let `false` = "false"
  public static let int = "int"
  public static let left = "left"
  public static let none = "none"
  public static let pair = "pair"
  public static let primitive = "prim"
  public static let right = "right"
  public static let some = "some"
  public static let string = "string"
  public static let `true` = "true"
  public static let unit = "unit"
}

/// An abstract representation of a Micheline param.
///
/// - SeeAlso: https://tezos.gitlab.io/master/whitedoc/michelson.html
public protocol MichelineParam {
  var json: [String: Any] { get }
}
