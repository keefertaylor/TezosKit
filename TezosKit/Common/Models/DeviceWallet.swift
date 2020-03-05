// Copyright Keefer Taylor, 2020

import Base58Swift
import BigInt
import Foundation
import Security
import Sodium

/// A wallet that uses on device storage to manage keys. This is an abstract class, please use one of the concrete subclasses.
public class DeviceWallet: SignatureProvider {
  /// References to the secret keys
  private let secretKey: EllipticCurveKeyPair.PrivateKey

  /// The public key.
  public let publicKey: PublicKeyProtocol

  /// The address of the underlying keys
  public var address: String {
    return self.publicKey.publicKeyHash
  }

  /// - Parameter prompt: A prompt to use when asking the wallet to sign bytes.
  internal init?(prompt: String, token: EllipticCurveKeyPair.Token, publicKeyLabel: String, privateKeyLabel: String) {
    let publicAccessControl = EllipticCurveKeyPair.AccessControl(
      protection: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
      flags: []
    )
    let privateAccessControl = EllipticCurveKeyPair.AccessControl(
      protection: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
      flags: [.userPresence, .privateKeyUsage]
    )
    let config = EllipticCurveKeyPair.Config(
      publicLabel: publicKeyLabel,
      privateLabel: privateKeyLabel,
      operationPrompt: prompt,
      publicKeyAccessControl: publicAccessControl,
      privateKeyAccessControl: privateAccessControl,
      token: token
    )
    let manager = EllipticCurveKeyPair.Manager(config: config)

    guard
      let keys = try? manager.keys(),
      let rawPublicKey = try? keys.public.data().raw
    else {
      return nil
    }
    self.secretKey = keys.private

    guard let compressedPublicKeyBytes = CryptoUtils.compressKey(Array(rawPublicKey)) else {
      return nil
    }
    self.publicKey = PublicKey(bytes: compressedPublicKeyBytes, signingCurve: .p256)
  }

  // TODO(keefertaylor): This method is duplicated with PrivateKey and assumes the watermark is always an operation.
  //                     Refactor and genericize.
  public func sign(_ hex: String) -> [UInt8]? {
    // Prepare bytes for signing.
    guard let bytes = Sodium.shared.utils.hex2bin(hex) else {
      return nil
    }
    let watermarkedOperation = Prefix.Watermark.operation + bytes

    guard
      let hashedBytesForSigning = Sodium.shared.genericHash.hash(message: watermarkedOperation, outputLength: 32)
      else {
        return nil
    }

    // Sign the bytes and copy out the result.
    var error: Unmanaged<CFError>?
    let signature: Data = SecKeyCreateSignature(
      self.secretKey.underlying,
      SecKeyAlgorithm.ecdsaSignatureDigestX962SHA256,
      Data(hashedBytesForSigning) as CFData,
      &error
      )! as Data

    // The signature returned to us is a ASN.1 DER sequence which encodes the 64 byte signature. Parse the DER to
    // obtain the raw signature.
    // See: https://medium.com/@maxchuquimia/decoding-asn-1-der-sequences-in-swift-1b801c6c8cc9
    //
    // Note: These lines could be replaced with the following implementation from CryptoKit, however, CryptoKit is only
    // available on iOS 13.0+ and MacOS 15.0+, which greatly restricts the compatibility of this library.
    // ```
    //    let ecdsaSignature = try! P256.Signing.ECDSASignature(derRepresentation: signature)
    //    return ecdsaSignature.rawRepresentation.bytes
    // ```
    guard let decoded = ASN1DERDecoder.decode(data: signature) else {
      return nil
    }

    // Scan forward until we hit a 0 byte (two 0 octets), indicating the end of the sequence in ASN1 DER formatting.
    return decoded.reduce([UInt8](), { (sum, next) -> [UInt8] in
      let filter = SimpleScanner(data: next.data)
      if filter.scan(distance: 1)?.firstByte == 0x0 {
        return sum + filter.scanToEnd()!
      } else {
        return sum + next.data
      }
    })
  }
}
