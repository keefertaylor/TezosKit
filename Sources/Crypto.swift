import Foundation
import CommonCrypto
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

  private static let sodium: Sodium = Sodium()

  /**
   * Sign a forged operation with the given secret key.
   *
   * TODO: Modify this method to operate on a edsk base 58 encoded key rather than expecting to be
   *       passed the secret key.
   */
  public static func signForgedOperation(operation: String, secretKey: [UInt8]) -> String? {
    let watermarkedOperation = sodium.utils.hex2bin(operationWaterMark + operation)!

    guard let hashedOperation = sodium.genericHash.hash(message: watermarkedOperation, outputLength: 32),
          let signedOperation = sodium.sign.signature(message: hashedOperation, secretKey: secretKey) else {
      return nil
    }

    let encodedOperation = encode(message: signedOperation, prefix: signedOperationPrefix)
    return encodedOperation
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
  public static func tezosPublicKey(from key: [UInt8]) -> String {
    return encode(message: key, prefix: publicKeyPrefix)
  }

  /**
   * Generates a Tezos private key from the given input private key.
   */
  public static func tezosSecretKey(from key: [UInt8]) -> String {
    return encode(message: key, prefix: secretKeyPrefix)
  }

  /**
   * Generates a Tezos public key hash (An address) from the given input public key.
   */
  public static func tezosPublicKeyHash(from key: [UInt8]) -> String {
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
  private static func encode(message: [UInt8], prefix: [UInt8]) -> String {
    let prefixedKey = prefix + message
    let prefixedKeyCheckSum = calculateCheckSum(prefixedKey)
    let prefixedKeyWithCheckSum = prefixedKey + prefixedKeyCheckSum
    let data = Data(prefixedKeyWithCheckSum)
    return String(base58Encoding: data)
  }

  /**
   * Calculate a checksum for a given input by hashing twice and then taking the first four bytes.
   */
  private static func calculateCheckSum(_ input: [UInt8]) -> [UInt8] {
    let doubleHashedData = Data(input).sha256().sha256()
    let doubleHashedArray = Array(doubleHashedData)
    return Array(doubleHashedArray.prefix(4))
  }

  /** Create a sha256 hash of the given data. */
  private func sha256(_ data: Data) -> Data? {
    guard let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH)) else {
      return nil
    }
    CC_SHA256((data as NSData).bytes,
              CC_LONG(data.count),
              res.mutableBytes.assumingMemoryBound(to: UInt8.self))
    return res as Data
  }

  /** Please do not instantiate this static helper class. */
  private init() {}
}

extension Data {
    var bytes: [UInt8] {
        var byteArray = [UInt8](repeating: 0, count: self.count)
        self.copyBytes(to: &byteArray, count: self.count)
        return byteArray
    }
}
