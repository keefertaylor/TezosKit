// Copyright Keefer Taylor, 2019.

/// An RPC which fetches sent transactions from an account.
public class GetSentTransactionsRPC: ConseilQueryRPC<[Transaction]> {
  /// - Parameters:
  ///   - account: The account to query.
  ///   - limit: The number of items to return.
  ///   - apiKey: The API key to send in the request headers.
  ///   - platform: The platform to query.
  ///   - network: The network to query.
  public init?(account: String, limit: Int, apiKey: String, platform: ConseilPlatform, network: ConseilNetwork) {
    let predicates = [
      ConseilQuery.Predicates.predicateWith(field: "kind", set: ["transaction"]),
      ConseilQuery.Predicates.predicateWith(field: "source", set: [account])
    ]
    let orderBy = ConseilQuery.OrderBy.orderBy(field: "timestamp")
    let query = ConseilQuery.query(predicates: predicates, orderBy: orderBy, limit: limit)

    super.init(
      query: query,
      entity: .operation,
      apiKey: apiKey,
      platform: platform,
      network: network,
      responseAdapterClass: TransactionsResponseAdapter.self
    )
  }
}
