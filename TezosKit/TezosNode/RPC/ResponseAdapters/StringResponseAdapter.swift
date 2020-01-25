// Copyright Keefer Taylor, 2018

import Foundation

/// Parse the given data as a string.
///
/// Note that the API returns strings enclosed inside of whitespace, newlines and double quotes.
/// These characters are stripped by this adapter.
public class StringResponseAdapter: AbstractResponseAdapter<String> {
  public override class func parse(input: Data) -> String? {
    guard
      let decodedString = String(data: input, encoding: .utf8)
    else {
      return nil
    }

    let characterSet = CharacterSet(charactersIn: "\"").union(.whitespacesAndNewlines)
    let normalizedString = decodedString.trimmingCharacters(in: characterSet)
    // RPC API will just pass through `null` when response is not found.
    guard normalizedString != "null" else {
      return nil
    }

    return normalizedString
  }
}
