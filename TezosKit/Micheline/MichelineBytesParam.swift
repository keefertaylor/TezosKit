// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of a bytes parameter in micheline.
// TODO: Consider alternative constructors.
public struct MichelineBytesParam: MichelineParam {
  public let json: [String: Any]

  public init(hex: Hex) {
    json = [ "bytes": hex ]
  }
}
