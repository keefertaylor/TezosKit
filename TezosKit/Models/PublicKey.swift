// Copyright Keefer Taylor, 2019

import Foundation
import TezosCrypto

public protocol PublicKey {
  var base58CheckRepresentation: String { get }
}
//public protocol SecretKey {
//  var base58CheckRepresentation: String { get }
//}
//
///// A structure representing public and private keys for a wallet in the Tezos ecosystem.
//public struct Keys {
//  public let publicKey: PublicKey
//  public let secretKey: SecretKey
//}
//
//extension Keys: Equatable {
//  public static func == (lhs: Keys, rhs: Keys) -> Bool {
//    return lhs.publicKey.base58CheckRepresentation == rhs.publicKey.base58CheckRepresentation &&
//      lhs.secretKey.base58CheckRepresentation == rhs.secretKey.base58CheckRepresentation
//  }
//}

extension TezosCrypto.PublicKey: PublicKey {
}
//
//extension TezosCrypto.SecretKey: SecretKey {
//}
