// Copyright Keefer Taylor, 2019.

import Foundation

// TODO: Support annots
// TODO: REmove contract deploy / code?
// TODO: Comments

/// An abstract representation of a Micheline param.
///
/// - SeeAlso: https://tezos.gitlab.io/master/whitedoc/michelson.html
public protocol MichelineParam {
  var json: [String: Any] { get }
}
