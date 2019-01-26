// Copyright Keefer Taylor, 2018

import Foundation

/**
 * A static utility class which provides functionality for encoding and decoding JSON.
 */
public class JSONUtils {
  /**
   * Returns a JSON encoded string representation of a given string.
   */
  public static func jsonString(for string: String) -> String? {
    return "\"" + string + "\""
  }

  /**
   * Returns a JSON encoded string representation of a given array.
   */
  public static func jsonString(for array: [[String: Any]]) -> String? {
    return jsonString(forUntypedObject: array)
  }

  /**
   * Returns a JSON encoded string representation of a given dictionary.
   */
  public static func jsonString(for dictionary: [String: Any]) -> String? {
    return jsonString(forUntypedObject: dictionary)
  }

  /**
   * Private untyped helper that returns a JSON encoded representation of the given object.
   *
   * The only supported objects are Arrays and Dictionaries.
   */
  private static func jsonString(forUntypedObject object: Any) -> String? {
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

  /** Please do not instantiate this static utility class. */
  private init() {}
}
