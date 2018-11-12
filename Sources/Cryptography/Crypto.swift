// Copyright Keefer Taylor, 2018

import CommonCrypto
import Foundation
import Sodium

/**
 * A static helper class that provides utility functions for cyptography.
 */
public class Crypto {
  private static let publicKeyPrefix: [UInt8] = [13, 15, 37, 217] // edpk
  private static let secretKeyPrefix: [UInt8] = [43, 246, 78, 7] // edsk
  private static let publicKeyHashPrefix: [UInt8] = [6, 161, 159] // tz1

  private static let signedOperationPrefix: [UInt8] = [9, 245, 205, 134, 18] // edsig

  private static let operationWaterMark = "03"

  // Length of checksum appended to Base58Check encoded strings.
  private static let checksumLength = 4

  private static let sodium: Sodium = Sodium()

  /**
   * Extract a base58check encoded public key prefixed with edpk from a given base58check encoded
   * secret key prefixed with edsk.
   */
  public static func extractPublicKey(secretKey: String) -> String? {
    guard let publicKeyBytes = self.extractPublicKeyBytes(secretKey: secretKey) else {
      return nil
    }
    return encode(message: publicKeyBytes, prefix: publicKeyPrefix)
  }

  /**
   * Extract a base58check encoded public key hash prefixed with tz1 from a given base58check
   * encoded secret key prefixed with edsk.
   */
  public static func extractPublicKeyHash(secretKey: String) -> String? {
    guard let publicKeyBytes = self.extractPublicKeyBytes(secretKey: secretKey) else {
      return nil
    }
    return tezosPublicKeyHash(from: publicKeyBytes)
  }

  /**
   * Check that a given address is valid public key hash address.
   */
  public static func validateAddress(address: String) -> Bool {
    guard let decodedData = Data(base58Decoding: address) else {
      return false
    }
    let decodedBytes = decodedData.bytes

    // Check that the prefix is correct.
    for (i, byte) in publicKeyHashPrefix.enumerated() {
      if decodedBytes[i] != byte {
        return false
      }
    }

    // Check that checksum is correct.
    let checksumStartIndex = decodedBytes.count - checksumLength
    let addressWithoutChecksum = decodedBytes[0 ..< checksumStartIndex]
    let checksum = decodedBytes[checksumStartIndex...]
    guard let expectedChecksum = self.calculateChecksum(Array(addressWithoutChecksum)) else {
      return false
    }

    for (i, byte) in checksum.enumerated() {
      if expectedChecksum[i] != byte {
        return false
      }
    }
    return true
  }

  /**
   * Verify that the given signature is a signed version of the given bytes by the secret key
   * associated with the given public key.
   */
  public static func verifyBytes(bytes: [UInt8], signature: [UInt8], publicKey: String) -> Bool {
    guard let decodedPublicKeyBytes = self.decodedKey(from: publicKey, prefix: publicKeyPrefix) else {
      return false
    }
    return sodium.sign.verify(message: bytes, publicKey: decodedPublicKeyBytes, signature: signature)
  }

  /**
   * Sign a forged operation with the given secret key.
   *
   * @param operation A hex encoded string representing the forged operation
   * @param secretKey A base58check encoded secret key prefixed with 'edsk' which will sign the
   *        operation.
   * @return A OperationSigningResult with the results of the signing if successful, otherwise nil.
   */
  public static func signForgedOperation(operation: String,
                                         secretKey: String) -> OperationSigningResult? {
    guard let decodedSecretKeyBytes = self.decodedKey(from: secretKey, prefix: secretKeyPrefix) else {
      return nil
    }

    guard let watermarkedOperation = sodium.utils.hex2bin(operationWaterMark + operation),
      let hashedOperation = sodium.genericHash.hash(message: watermarkedOperation,
                                                    outputLength: 32),
      let signature = sodium.sign.signature(message: hashedOperation,
                                            secretKey: decodedSecretKeyBytes),
      let signatureHex = sodium.utils.bin2hex(signature),
      let edsig = encode(message: signature, prefix: signedOperationPrefix) else {
      return nil
    }

    let sbytes = operation + signatureHex
    return OperationSigningResult(operationBytes: hashedOperation,
                                  signature: signature,
                                  edsig: edsig,
                                  sbytes: sbytes)
  }

  /**
   * Generates a KeyPair given a hex-encoded seed string.
   */
  public static func keyPair(from seedString: String) -> KeyPair? {
    guard let seed = sodium.utils.hex2bin(seedString),
      let keyPair = sodium.sign.keyPair(seed: seed) else {
      return nil
    }
    return keyPair
  }

  /**
   * Generates a Tezos public key from the given input public key.
   */
  public static func tezosPublicKey(from key: [UInt8]) -> String? {
    return encode(message: key, prefix: publicKeyPrefix)
  }

  /**
   * Generates a Tezos private key from the given input private key.
   */
  public static func tezosSecretKey(from key: [UInt8]) -> String? {
    return encode(message: key, prefix: secretKeyPrefix)
  }

  /**
   * Generates a Tezos public key hash (An address) from the given input public key.
   */
  public static func tezosPublicKeyHash(from key: [UInt8]) -> String? {
    guard let hash = sodium.genericHash.hash(message: key, key: [], outputLength: 20) else {
      return ""
    }
    return encode(message: hash, prefix: publicKeyHashPrefix)
  }

  /**
   * Encode a Base58 String from the given message and prefix.
   *
   * The returned address is a Base58 encoded String with the following format:
   *    [prefix][key][4 byte checksum]
   */
  private static func encode(message: [UInt8], prefix: [UInt8]) -> String? {
    let prefixedKey = prefix + message
    guard let prefixedKeyCheckSum = calculateChecksum(prefixedKey) else {
      return nil
    }

    let prefixedKeyWithCheckSum = prefixedKey + prefixedKeyCheckSum
    let data = Data(prefixedKeyWithCheckSum)
    return String(base58Encoding: data)
  }

  /**
   * Calculate a checksum for a given input by hashing twice and then taking the first four bytes.
   */
  private static func calculateChecksum(_ input: [UInt8]) -> [UInt8]? {
    guard let hashedData = sha256(Data(input)),
      let doubleHashedData = sha256(hashedData) else {
      return nil
    }
    let doubleHashedArray = Array(doubleHashedData)
    return Array(doubleHashedArray.prefix(checksumLength))
  }

  /** Create a sha256 hash of the given data. */
  private static func sha256(_ data: Data) -> Data? {
    guard let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH)) else {
      return nil
    }
    CC_SHA256((data as NSData).bytes,
              CC_LONG(data.count),
              res.mutableBytes.assumingMemoryBound(to: UInt8.self))
    return res as Data
  }

  /** Decode an original key from the Base58 encoded key containing a prefix and checksum. */
  private static func decodedKey(from encodedKey: String, prefix: [UInt8]) -> [UInt8]? {
    guard let decodedKey = Data(base58Decoding: encodedKey) else {
      return nil
    }

    // Decoded key will have extra bytes at the beginning for the prefix and extra bytes at the end
    // as a checksum. Drop these bytes in order to get the original key.
    var decodedSecretKeyBytes = Array(decodedKey)
    decodedSecretKeyBytes.removeSubrange(0 ..< prefix.count)
    decodedSecretKeyBytes.removeSubrange((decodedSecretKeyBytes.count - checksumLength)...)

    return decodedSecretKeyBytes
  }

  /**
   * Extract a bytes for a public key from a given base58check encoded secret key prefixed with
   * "edsk".
   */
  public static func extractPublicKeyBytes(secretKey: String) -> [UInt8]? {
    guard let decodedSecretKeyBytes = self.decodedKey(from: secretKey, prefix: secretKeyPrefix) else {
      return nil
    }
    return Array(decodedSecretKeyBytes[32...])
  }

  /** Please do not instantiate this static helper class. */
  private init() {}
}
