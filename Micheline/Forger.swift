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

    var n = abs(signedInt)
    let binary = String(signedInt, radix: 2, uppercase: false)
    // Drop any negative signs.
    let trimmedBinary = signedInt < 0 ? String(binary.dropFirst(1)) : binary

    var result: [UInt8] = []
    for i in stride(from: 0, to: trimmedBinary.count, by: 7) {
      var byte: UInt8 = 0
      let end = i + 8 > trimmedBinary.count ? trimmedBinary.count : i + 8
      var next = trimmedBinary.substring(from: i, to: end)
      next = String(repeating: "0", count: 8 - next.count) + next
      print("Oh hey, I got \(next) which is \(next.count) chars")
      let nextByte = UInt8(next, radix: 2)!
      if i == 0 {
        byte = nextByte & 0x3f
        n = n >> 6
      } else {
        byte = nextByte & 0x7f
        n = n >> 7
      }

      if signedInt < 0 && i == 0 {
        byte = byte | 0x40 // Set sign flag
      }

      if (i + 7 < trimmedBinary.count) {
        byte = byte | 0x80 // Set next byte flag
      }
      result.append(byte)
    }

    if trimmedBinary.count % 7 == 0 {
      result[result.count - 1] = result[result.count - 1] | 0x80
      result.append(1)
    }

    var resultHex = ""
    for r in result {
      var hex = Sodium.shared.utils.bin2hex([r])!
      hex = "0" + hex
      hex = String(hex.suffix(2))
      print("hex") 
      resultHex = resultHex + hex
    }
    return resultHex
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

public extension String {
  public func substring(from: Int, to: Int) -> String {
    let start = index(startIndex, offsetBy: from)
    let end = index(start, offsetBy: to - from)
    return String(self[start ..< end])
  }
}
