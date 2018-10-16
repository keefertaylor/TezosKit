import Foundation
import CommonCrypto

public class Crypto {
  private static let publicKeyPrefix: [UInt8] = [13, 15, 37, 217] // edpk
  private static let privateKeyPrefix: [UInt8] = [43, 246, 78, 7] // edsk



  private static func encode(key: [UInt8], prefix: [UInt8]) -> String {
    let prefixedKey = prefix + key
    let prefixedKeyCheckSum = calculateCheckSum(prefixedKey)
    let prefixedKeyWithCheckSum = prefixedKey + prefixedKeyCheckSum
    let data = Data(prefixedKeyWithCheckSum)
    return String(base58Encoding: data)
  }

  private static func calculateCheckSum(_ input: [UInt8]) -> [UInt8] {
    let doubleHashedData = Data(input).sha256().sha256()
    let doubleHashedArray = Array(doubleHashedData)
    return Array(doubleHashedArray.prefix(4))
  }

  private func sha256(_ data: Data) -> Data? {
    guard let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH)) else {
      return nil
    }
    CC_SHA256((data as NSData).bytes,
              CC_LONG(data.count),
              res.mutableBytes.assumingMemoryBound(to: UInt8.self))
    return res as Data
  }
}
