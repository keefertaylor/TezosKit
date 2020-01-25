// Copyright Keefer Taylor, 2018

import Foundation

/// Parse a given response as a string representing an amount of Tez.
public class TezResponseAdapter: AbstractResponseAdapter<Tez> {
  public override class func parse(input: Data) -> Tez? {
    guard let balanceString = StringResponseAdapter.parse(input: input) else {
      return nil
    }
    return Tez(balanceString)
  }
}
