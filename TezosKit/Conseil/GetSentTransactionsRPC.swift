// Copyright Keefer Taylor, 2019.

/// An RPC which fetches sent transactions from an account.
public class GetSentTransactionsRPC: RPC<[Transaction]> {
  /// - Parameters:
  ///   - account: The account to query.
  ///   - limit: The number of items to return.
  ///   - apiKey: The API key to send in the request headers.
  ///   - platform: The platform to query.
  ///   - network: The network to query.
  public init?(account: String, limit: Int, apiKey: String, platform: ConseilPlatform, network: ConseilNetwork) {
    guard let escapedPlatform = platform.rawValue.addingPercentEncoding(
                withAllowedCharacters: CharacterSet.urlQueryAllowed
          ),
          let escapedNetwork = network.rawValue.addingPercentEncoding(
                withAllowedCharacters: CharacterSet.urlQueryAllowed
      ) else {
        return nil
    }
    let endpoint = "/v2/data/\(escapedPlatform)/\(escapedNetwork)/operations"
    let headers = [
      Header.contentTypeApplicationJSON,
      Header(field: "apiKey", value: apiKey)
    ]

    let predicates = [
      ConseilQuery.Predicates.predicateWith(field: "kind", set: ["transaction"]),
      ConseilQuery.Predicates.predicateWith(field: "source", set: [account])
    ]
    let orderBy = ConseilQuery.OrderBy.orderBy(field: "timestamp")
    let payload: [String: Any] = ConseilQuery.query(predicates: predicates, orderBy: orderBy, limit: limit)

    super.init(
      endpoint: endpoint,
      headers: headers,
      responseAdapterClass: TransactionsResponseAdapter.self,
      payload: JSONUtils.jsonString(for: payload)
    )
  }
}
