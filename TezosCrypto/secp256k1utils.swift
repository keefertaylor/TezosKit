//
//  secp256k1utils.swift
//  TezosCrypto
//
//  Created by Keefer Taylor on 4/30/19.
//  Copyright © 2019 Keefer Taylor. All rights reserved.
//

import Foundation
import secp256k1

public enum Secp {
  public enum Error: Swift.Error {
    case invalidPublicKey
    case invalidPrivateKey
    case invalidSignature
    case invalidRecoveryID
    case internalError
  }

  public enum Compression {
    case uncompressed
    case compressed

    var flag: UInt32 {
      switch self {
      case .uncompressed:
        return UInt32(SECP256K1_EC_UNCOMPRESSED)
      case .compressed:
        return UInt32(SECP256K1_EC_COMPRESSED)
      }
    }

    var pubkeyLength: Int {
      switch self {
      case .uncompressed:
        return 65
      case .compressed:
        return 33
      }
    }
  }

  public enum NonceFunction: String {
    case `default` = "default"
    case rfc6979 = "nonce_function_rfc6979"

    var function: secp256k1_nonce_function {
      switch self {
      case .default:
        return secp256k1_nonce_function_default
      case .rfc6979:
        return secp256k1_nonce_function_rfc6979
      }
    }
  }

  public static func derivePublicKey(
    for privkey: [UInt8],
    with compression: Compression = .uncompressed
  ) throws -> [UInt8] {
    let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY))!
    defer {
      secp256k1_context_destroy(context)
    }

    var cPubkey = secp256k1_pubkey()
    var pubkeyLen = compression.pubkeyLength
    var pubkey: [UInt8] = Array(repeating: 0, count: pubkeyLen)

    guard secp256k1_context_randomize(context, privkey) == 1,
      secp256k1_ec_pubkey_create(context, &cPubkey, privkey) == 1,
      secp256k1_ec_pubkey_serialize(context, &pubkey, &pubkeyLen, &cPubkey, compression.flag) == 1 else {
        throw Error.internalError
    }

    return pubkey
  }

  public static func sign(msg: [UInt8], with privkey: [UInt8], nonceFunction: NonceFunction) throws -> [UInt8] {
    guard isValidPrivateKey(privkey) else {
      throw Error.invalidPrivateKey
    }

    let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY))!
    defer {
      secp256k1_context_destroy(context)
    }

    var cSignature = secp256k1_ecdsa_signature()

    guard secp256k1_ecdsa_sign(context, &cSignature, msg, privkey, nonceFunction.function, nil) == 1 else {
      throw Error.internalError
    }

    var sigLen = 74
    var signature = [UInt8](repeating: 0, count: sigLen)

    guard secp256k1_ecdsa_signature_serialize_der(context, &signature, &sigLen, &cSignature) == 1,
      secp256k1_ecdsa_signature_parse_der(context, &cSignature, &signature, sigLen) == 1 else {
        throw Error.internalError
    }

    return Array(signature[..<sigLen])
  }

  public static func isValidPrivateKey(_ privkey: [UInt8]) -> Bool {
    guard privkey.count == 32 else {
      return false
    }

    let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY))!
    defer {
      secp256k1_context_destroy(context)
    }

    return secp256k1_ec_seckey_verify(context, privkey) == 1
  }
}
