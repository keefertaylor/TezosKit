// Copyright Keefer Taylor, 2019

import Foundation
import TezosCrypto

/// Opaque representation of a public key in TezosKit.
public protocol PublicKey {
  var base58CheckRepresentation: String { get }
}

/// Provide conformance of TezosCrypto.PublicKey to TezosKit.PublicKey.
extension TezosCrypto.PublicKey: PublicKey {
}
