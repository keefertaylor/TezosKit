// Copyright Keefer Taylor, 2019.

/// An RPC which fetches originated accounts for an account.
public class GetOriginatedAccounts: ConseilQueryRPC<[[String: Any]]> {
  /// - Parameters:
  ///   - account: The account to query.
  ///   - limit: The number of items to return.
  public init(account: String, limit: Int) {
    let predicates: [ConseilPredicate] = [
      ConseilQuery.Predicates.predicateWith(field: "manager", set: [account])
    ]
    let orderBy: ConseilOrderBy = ConseilQuery.OrderBy.orderBy(field: "block_level")
    let query: [String: Any] = ConseilQuery.query(predicates: predicates, orderBy: orderBy, limit: limit)

    super.init(
      query: query,
      entity: .account,
      responseAdapterClass: JSONArrayResponseAdapter.self
    )
  }
}
