// Copyright Keefer Taylor, 2019.

/// An RPC which fetches sent transactions from an account.
public class GetSentTransactionsRPC: ConseilQueryRPC<[Transaction]> {
  /// - Parameters:
  ///   - account: The account to query.
  ///   - limit: The number of items to return.
  public init(account: String, limit: Int) {
    let predicates = [
      ConseilQuery.Predicates.predicateWith(field: "kind", set: ["transaction"]),
      ConseilQuery.Predicates.predicateWith(field: "source", set: [account])
    ]
    let orderBy = ConseilQuery.OrderBy.orderBy(field: "timestamp")
    let query = ConseilQuery.query(predicates: predicates, orderBy: orderBy, limit: limit)

    super.init(
      query: query,
      entity: .operation,
      responseAdapterClass: TransactionsResponseAdapter.self
    )
  }
}
