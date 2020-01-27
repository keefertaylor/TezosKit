// Copyright Keefer Taylor, 2020

import Foundation

/// Opaque representation of a public key in TezosKit.	
public protocol PublicKeyProtocol {
  var base58CheckRepresentation: String { get }
  var signingCurve: EllipticalCurve { get }
}
