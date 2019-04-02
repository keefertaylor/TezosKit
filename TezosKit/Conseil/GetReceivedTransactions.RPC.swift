// Copyright Keefer Taylor, 2019.

/// An RPC which fetches received transactions for an account.
public class GetReceivedTransactionsRPC: ConseilQueryRPC<[Transaction]> {
  /// - Parameters:
  ///   - account: The account to query.
  ///   - limit: The number of items to return.
  public init(account: String, limit: Int) {
    let predicates: [ConseilPredicate] = [
      ConseilQuery.Predicates.predicateWith(field: "kind", set: ["transaction"]),
      ConseilQuery.Predicates.predicateWith(field: "destination", set: [account])
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
