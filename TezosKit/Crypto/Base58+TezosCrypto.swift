// Copyright Keefer Taylor, 2019.

import Base58Swift
import Foundation

/// Helper functions on Base58Swift for TezosCrypto
extension Base58 {
  /// Encode a Base58Check string from the given message and prefix.
  ///
  /// The returned address is a Base58 encoded String with the following format: [prefix][key][4 byte checksum]
  public static func encode(message: [UInt8], prefix: [UInt8]) -> String {
    let prefixedMessage = prefix + message
    return Base58.base58CheckEncode(prefixedMessage)
  }

  /// Decode a Base58Check string to bytes and verify that the bytes begin with the given prefix.
  ///
  /// - Parameters:
  ///   - string: The Base58Check string to decode.
  ///   - prefix: The expected prefix bytes after decoding.
  /// - Returns: The raw bytes without the given prefix if the string was valid Base58Check and had the expected prefix,
  ///            otherwise, nil.
  public static func base58CheckDecodeWithPrefix(string: String, prefix: [UInt8]) -> [UInt8]? {
    guard let bytes = Base58.base58CheckDecode(string),
          bytes.prefix(Prefix.Keys.secret.count).elementsEqual(prefix) else {
        return nil
    }
    return Array(bytes.suffix(from: Prefix.Keys.secret.count))
  }
}
