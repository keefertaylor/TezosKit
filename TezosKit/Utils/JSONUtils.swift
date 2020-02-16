// Copyright Keefer Taylor, 2018

import Foundation

/// Marks an object as codable to JSON.
public protocol JSONCodable {}

/// Mark arrays and dictionaries as JSONCodable.
extension Dictionary: JSONCodable where Key == String {}
extension Array: JSONCodable {}

/// A facade for a JSON parsing library.
public enum JSONUtils {
  /// Returns a JSON encoded string representation of a given string.
  public static func jsonString(for string: String) -> String? {
    return "\"" + string + "\""
  }

  /// Return a JSON encoded string representation of a given integer.
  public static func jsonString(for int: Int) -> String? {
    return jsonString(for: String(int))
  }

  /// Return a JSON encoded sstring representation of the given codable.
  public static func jsonString(for object: JSONCodable) -> String? {
    do {
      var options: JSONSerialization.WritingOptions = []
      if #available(iOS 11.0, OSX 10.13, *) {
        options = [.sortedKeys]
      }
      let jsonData = try JSONSerialization.data(withJSONObject: object, options: options)
      guard let jsonPayload = String(data: jsonData, encoding: .utf8) else {
        return nil
      }
      return jsonPayload
    } catch {
      return nil
    }
  }
}
