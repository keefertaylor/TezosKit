// Copyright Keefer Taylor, 2019

import Base58Swift
import Foundation
import Sodium

/// A utility class that forges micheline to hex.
public enum Forger {
  /// Encode a boolean to hex.
  public static func forge(bool: Bool) -> String {
    return bool ? "ff" : "00"
  }

  /// Encode an address to hex
  public static func forge(address: String) -> String? {
    // TODO: Does this exist anywhere?
    let prefixLength = 3
    let prefix = address.prefix(prefixLength)
    guard let decodedHex = Base58.base58CheckDecodeSuffix(address, from: prefixLength) else {
      return nil
    }

    switch prefix {
    case "tz1":
      return "0000" + decodedHex
    case "tz2":
      return "0001" + decodedHex
    case "tz3":
      return "0002" + decodedHex
    case "KT1":
      return "01" + decodedHex + "00"
    default:
      return nil
    }
  }

  /// Encode a signed int to hex
  public static func forge(signedInt: Int) -> String? {
    guard signedInt != 0 else {
      return "00"
    }
    return nil
  }

  /// Encode a unsigned int to hex
  public static func forge(unsignedInt: UInt) -> String? {
    let binary = String(unsignedInt, radix: 2, uppercase: false)
    let padding = 7 - (binary.count % 7)
    var paddedBinary = String(repeating: "0", count: padding) + binary

    var unprefixedBytes: [String] = []
    while paddedBinary.count > 0 {
      unprefixedBytes.append(String(paddedBinary.prefix(7)))
      paddedBinary = String(paddedBinary.dropFirst(7))
    }

    let prefixedBytes = unprefixedBytes.reversed().enumerated().map { (index, unprefixedByte) -> String in
      guard index != unprefixedBytes.count - 1 else {
        return "0" + unprefixedByte
      }
      return "1" + unprefixedByte
    }

    let final: String = prefixedBytes.reduce("") { (acc, next) in
      acc + next
    }
    let resultInt = Int(final, radix: 2)!
    return String(format:"%02X", resultInt)
  }

  /// Encode a unsigned int to hex
  public static func forge(branch: String) -> String? {
    return Base58.base58CheckDecodeSuffix(branch, from: 2)
  }
}

extension Base58 {
  /// Decode a base58check encoded string and drop a prefix of the given length.
  ///
  /// - Parameters:
  ///   - input: The base58check input string.
  ///   - offset: The lenght of the prefix to drop.
  /// - Returns: A hex encoded representation of the string, or nil if the input was invalid.
  fileprivate static func base58CheckDecodeSuffix(_ input: String, from offset: Int) -> String? {
    guard let decoded = Base58.base58CheckDecode(input) else {
      return nil
    }
    let suffix = Array(decoded.suffix(from: offset))
    return Sodium.shared.utils.bin2hex(suffix)
  }
}
