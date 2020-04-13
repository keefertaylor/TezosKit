// Copyright Keefer Taylor, 2019.

/// An RPC which fetches originated contracts for an account.
public class GetOriginatedContractsRPC: ConseilQueryRPC<[[String: Any]]> {
  /// - Parameters:
  ///   - account: The account to query.
  ///   - limit: The number of items to return.
  public init(account: String, limit: Int) {
    let predicates: [ConseilPredicate] = [
      ConseilQuery.Predicates.predicateWith(field: "source", set: [account]),
      ConseilQuery.Predicates.predicateWith(field: "kind", set: ["origination"]),
      ConseilQuery.Predicates.predicateWith(field: "status", set: ["applied"])
    ]
    let orderBy: ConseilOrderBy = ConseilQuery.OrderBy.orderBy(field: "block_level")
    let query: [String: Any] = ConseilQuery.query(predicates: predicates, orderBy: orderBy, limit: limit)

    super.init(
      query: query,
      entity: .operation,
      responseAdapterClass: JSONArrayResponseAdapter.self
    )
  }
}
