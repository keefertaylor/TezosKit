// Copyright Keefer Taylor, 2020.

import Base58Swift
import BigInt
import CommonCrypto
import EllipticCurveKeyPair
import Foundation
import Security
import Sodium

/// A wallet which stores keys in a device's secure enclave.
// TODO(keefertaylor): Write a strong warning about how iOS can arbitrarily reset this and it is not backed up.
// TODO(keefertaylor): Write a README.md about using this class.
// TODO(keefertaylor): Verify graceful behavior on a simulator.
public class SecureEnclaveWallet: SignatureProvider {
  /// Labels for keys in the enclave.
  private enum KeyLabels {
    public static let `public` = "com.keefertaylor.SecureEnclaveExample.public"
    public static let secret = "com.keefertaylor.SecureEnclaveExample.secret"
  }

  /// A key manager object.
  /// TODO(keefertaylor): Consider using less opinionated facade.
  private let manager: EllipticCurveKeyPair.Manager

  /// References to the public and private keys
  private let enclavePublicKey: EllipticCurveKeyPair.PublicKey
  private let enclaveSecretKey: EllipticCurveKeyPair.PrivateKey

  /// The TezosKit public key.
  public let publicKey: PublicKeyProtocol

  /// The address of a the key stored in secure enclave
  public var address: String {
    self.publicKey.publicKeyHash
  }

  public init?() {
    let publicAccessControl = EllipticCurveKeyPair.AccessControl(
      protection: kSecAttrAccessibleAlwaysThisDeviceOnly,
      flags: []
    )
    let privateAccessControl = EllipticCurveKeyPair.AccessControl(
      protection: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
      flags: [.userPresence, .privateKeyUsage]
    )
    let config = EllipticCurveKeyPair.Config(
      publicLabel: "payment.sign.public",
      privateLabel: "payment.sign.private",
      operationPrompt: "Confirm payment",
      publicKeyAccessControl: publicAccessControl,
      privateKeyAccessControl: privateAccessControl,
      token: .secureEnclave
    )
    self.manager = EllipticCurveKeyPair.Manager(config: config)

    guard
      let keys = try? self.manager.keys(),
      let rawPublicKey = try? keys.public.data().raw
    else {
      return nil
    }
    self.enclavePublicKey = keys.public
    self.enclaveSecretKey = keys.private

    // The secure enclave provides us a key in an uncompressed format and Tezos keys expect the compressed format.
    // A magic byte 0x04 indicates that the key is uncompressed. Compressed keys use 0x02 and 0x03 to indicate the
    // key is compressed and the value of the Y coordinate of the keys.
    let rawPublicKeyBytes = Array(rawPublicKey)
    guard
      let firstByte = rawPublicKeyBytes.first,
      let lastByte = rawPublicKeyBytes.last,
      // Expect an uncompressed key to have length = 65 bytes (two 32 byte coordinates, and 1 magic prefix byte)
      rawPublicKeyBytes.count == 65,
      // Expect the first byte of the public key to be a magic 0x04 byte, indicating an uncompressed key.
      firstByte == 4
    else {
      return nil
    }

    // Assign a new magic byte based on the Y coordinate's parity.
    // See: https://bitcointalk.org/index.php?topic=644919.0
    let magicByte: [UInt8] = lastByte % 2 == 0 ? [2] : [3]
    let xCoordinateBytes = rawPublicKeyBytes[1...32]
    let compressedPublicKeyBytes = magicByte + xCoordinateBytes
    self.publicKey = PublicKey(bytes: compressedPublicKeyBytes, signingCurve: .p256)
  }

  // TODO(keefertaylor): This method implicitly assumes that the bytes being signed are on operation. Reconsider.
  // TODO(keefertaylor): This logic is duplicated with `SecretKey`. Move somewhere common.
  // TODO(keefertaylor): It probably makes sense for these to operate on bytes, rather than strings.
  public func sign(_ hex: String) -> [UInt8]? {
    // Prepare bytes for signing.
    guard let bytes = Sodium.shared.utils.hex2bin(hex) else {
      return nil
    }
    let watermarkedOperation = Prefix.Watermark.operation + bytes

    guard
      var hashedBytesForSigning = Sodium.shared.genericHash.hash(message: watermarkedOperation, outputLength: 32)
    else {
      return nil
    }

    // Sign the bytes and copy out the result.
    var signatureLength = 128
    var signatureBytes = [UInt8](repeating: 0, count: signatureLength)
    guard
      SecKeyRawSign(
        self.enclaveSecretKey.underlying,
        .PKCS1,
        &hashedBytesForSigning,
        hashedBytesForSigning.count,
        &signatureBytes,
        &signatureLength
      ) == errSecSuccess
    else {
      return nil
    }
    let signature = Data(bytes: &signatureBytes, count: signatureLength)

    // The signature returned to us is a ASN.1 DER sequence which encodes the 64 byte signature. Parse the DER to
    // obtain the raw signature.
    // See: https://medium.com/@maxchuquimia/decoding-asn-1-der-sequences-in-swift-1b801c6c8cc9
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
