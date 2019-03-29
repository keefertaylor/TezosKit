// Copyright Keefer Taylor, 2019

import Foundation

public class TransactionsResponseAdapter: AbstractResponseAdapter<[Transaction]> {
  public override class func parse(input: Data) -> [Transaction]? {
    guard let transactions = JSONArrayResponseAdapter.parse(input: input) else {
      return nil
    }
    return transactions.compactMap { Transaction($0) }
  }
}
