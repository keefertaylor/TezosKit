// Copyright Keefer Taylor, 2019

import Foundation

public class ConseilTransactionResponseAdapter: AbstractResponseAdapter<[ConseilTransaction]> {
  public override class func parse(input: Data) -> [ConseilTransaction]? {
    guard let transactions = JSONArrayResponseAdapter.parse(input: input) else {
      return nil
    }

    return transactions.compactMap { ConseilTransaction($0) }
  }
}
