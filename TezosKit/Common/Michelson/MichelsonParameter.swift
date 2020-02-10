// Copyright Keefer Taylor, 2019.

import Foundation

/// String constants used in Micheline param JSON encoding.
internal enum MichelineConstants {
  public static let annotations = "annots"
  public static let args = "args"
  public static let primitive = "prim"
  public static let bytes = "bytes"
  public static let int = "int"
  public static let left = "Left"
  public static let `false` = "False"
  public static let none = "None"
  public static let pair = "Pair"
  public static let right = "Right"
  public static let some = "Some"
  public static let string = "string"
  public static let `true` = "True"
  public static let unit = "Unit"
}

/// An abstract representation of a Michelson param.
///
/// - SeeAlso: https://tezos.gitlab.io/master/whitedoc/michelson.html
public protocol MichelsonParameter {
  /// A dictionary representing the paramater as a JSON object.
  // TODO(keefertaylor): Make this JSON encodable or some other protocol.
  var networkRepresentation: Any { get } /*[String: Any] { get } */
}
