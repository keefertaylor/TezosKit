//
//  GetRecievedSmartContractTransactionsRPC.swift
//  TezosKit
//
//  Created by Simon Mcloughlin on 09/04/2020.
//

import Foundation

/// An RPC which fetches received transactions for an account, that came from smart contracts. For example if an account reiceved some FA1.2 tokens
public class GetReceivedSmartContractTransactionsRPC: ConseilQueryRPC<[Transaction]> {
  /// - Parameters:
  ///   - account: The account to query.
  ///   - limit: The number of items to return.
  public init(account: String, limit: Int) {
    let predicates: [ConseilPredicate] = [
      ConseilQuery.Predicates.predicateWith(field: "parameters", operation: .like, set: [account], inverse: false)
    ]
    let orderBy: ConseilOrderBy = ConseilQuery.OrderBy.orderBy(field: "timestamp")
    let query: [String: Any] = ConseilQuery.query(predicates: predicates, orderBy: orderBy, limit: limit)

    super.init(
      query: query,
      entity: .operation,
      responseAdapterClass: TransactionsResponseAdapter.self
    )
  }
}
