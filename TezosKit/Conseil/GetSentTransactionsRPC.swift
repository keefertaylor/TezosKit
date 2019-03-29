// Copyright Keefer Taylor, 2019.

// swiftlint:disable line_length

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

    let payload: [String: Any] = [
      "fields": [],
      "predicates": [
        [
          "field": "kind",
          "set": [
            "transaction"
          ],
          "operation": "eq",
          "inverse": false
        ],
        [
          "field": "source",
          "set": [
            "\(account)"
          ],
          "operation": "eq",
          "inverse": false
        ]
      ],
      "orderBy": [
        [
          "field": "timestamp",
          "direction": "desc"
        ]
      ],
      "limit": "\(limit)"
    ]

//    let payload = """
//      {"fields": [],"predicates": [{"field": "kind","set": ["transaction"],"operation": "eq","inverse": false}, {"field": "source","set": ["\(account)"],"operation": "eq","inverse": false}],"orderBy": [{"field": "timestamp","direction": "desc"}],"limit": \(limit)}
//    """

    super.init(
      endpoint: endpoint,
      headers: headers,
      responseAdapterClass: TransactionsResponseAdapter.self,
      payload: JSONUtils.jsonString(for: payload)
    )
  }
}
