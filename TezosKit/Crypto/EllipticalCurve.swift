// Copyright Keefer Taylor, 2019.

import Foundation

/// Elliptical curves that can be used in elliptical curve cryptographic operations.
public enum EllipticalCurve {
  case ed25519
  case secp256k1
  case p256
}
