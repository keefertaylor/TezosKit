// Copyright Keefer Taylor, 2018

import Foundation

/**
 * Parse the given data as a JSON encoded string representing a dictionary.
 */
public class JSONDictionaryResponseAdapter: AbstractResponseAdapter<[String: Any]> {
  public override class func parse(input: Data) -> [String: Any]? {
    do {
      let json = try JSONSerialization.jsonObject(with: input)
      guard let typedJSON = json as? Dictionary<String, Any> else {
        return nil
      }
      return typedJSON
    } catch {
      return nil
    }
  }
}
