// Copyright Keefer Taylor, 2018

import Foundation

/**
 * Parse a given response as a string representing an PeriodKind.
 */
public class PeriodKindResponseAdapter: AbstractResponseAdapter<PeriodKind> {
  public override class func parse(input: Data) -> PeriodKind? {
    guard let parsedString = StringResponseAdapter.parse(input: input),
      let periodKind = PeriodKind(rawValue: parsedString) else {
      return nil
    }
    return periodKind
  }
}
