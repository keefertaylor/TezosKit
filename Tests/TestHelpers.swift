// Copyright Keefer Taylor, 2019.

import Foundation
import TezosKit

// swiftlint:disable force_cast
// swiftlint:disable force_try

/// Common helpers for all TezosKit unit tests.
public enum Helpers {
  /// Fix the expected input to the expected output of Swift's JSON serializer.
  ///
  /// Expected output is taken from the human readable version of the JSON serialization format. Swift outputs JSON
  /// keys either (1) non-deterministically or (2) ordered by key. This function re-orders the expected outputs of a
  /// input JSON string by key so that asserts can work properly.
  public static func orderJSONString(_ expected: String) -> String {
    let data = expected.data(using: .utf8)!
    let dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    return JSONUtils.jsonString(for: dictionary)!
  }
}
