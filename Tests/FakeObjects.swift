// Copyright Keefer Taylor, 2019

import Foundation
import TezosKit

public struct FakePublicKey: PublicKey {
  public let base58CheckRepresentation: String
}

public struct FakeSecretKey: SecretKey {
  public let base58CheckRepresentation: String
}

