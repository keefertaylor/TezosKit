// Copyright Keefer Taylor, 2018

import Foundation

/**
 * Parse a given response as a string representing an Integer.
 */
public class IntegerResponseAdapter: AbstractResponseAdapter<Int> {
  public override class func parse(input: Data) -> Int? {
    guard let parsedString = StringResponseAdapter.parse(input: input),
      let integer = Int(parsedString) else {
      return nil
    }
    return integer
  }
}
