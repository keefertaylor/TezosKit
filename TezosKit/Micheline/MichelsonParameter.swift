// Copyright Keefer Taylor, 2019.

import Foundation

/// String constants used in Micheline param JSON encoding.
internal enum MichelineConstants {
  public static let args = "args"
  public static let bytes = "bytes"
  public static let `false` = "false"
  public static let int = "int"
  public static let left = "Left"
  public static let none = "none"
  public static let pair = "Pair"
  public static let primitive = "prim"
  public static let right = "Right"
  public static let some = "some"
  public static let string = "string"
  public static let `true` = "true"
  public static let unit = "unit"
}

/// An abstract representation of a Michelson param.
///
/// - SeeAlso: https://tezos.gitlab.io/master/whitedoc/michelson.html
public protocol MichelsonParameter {
  var networkRepresentation: [String: Any] { get }
}
