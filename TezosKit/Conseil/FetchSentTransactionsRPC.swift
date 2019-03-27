// Copyright Keefer Taylor, 2019.

// swiftlint:disable line_length

/// An RPC which fetches sent transactions from an account.
public class ConseilFetchSentTransactionRPC: RPC<[[String: Any]]> {
  /// - Parameters:
  ///   - account: The account to query.
  ///   - limit: The number of items to return.
  ///   - apiKey: The API key to send in the request headers.
  ///   - platform: The platform to query.
  ///   - network: The network to query.
  public init(account: String, limit: Int, apiKey: String, platform: ConseilPlatform, network: ConseilNetwork) {
    let endpoint = "/v2/data/" + platform.rawValue + "/" + network.rawValue + "/operations"
    let headers = [
      Header.contentTypeApplicationJSON,
      Header(field: "apiKey", value: apiKey)
    ]
    let payload = "{\"fields\": [\"timestamp\", \"source\", \"destination\", \"amount\", \"fee\"],\"predicates\": [{\"field\": \"kind\",\"set\": [\"transaction\"],\"operation\": \"eq\",\"inverse\": false}, {\"field\": \"source\",\"set\": [\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\"],\"operation\": \"eq\",\"inverse\": false}],\"orderBy\": [{\"field\": \"timestamp\",\"direction\": \"desc\"}],\"limit\": 100}"

    super.init(
      endpoint: endpoint,
      headers: headers,
      responseAdapterClass: JSONArrayResponseAdapter.self,
      payload: payload
    )
  }
}
