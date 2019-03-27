// Copyright Keefer Taylor, 2019.

/// An RPC which fetches sent transactions from an account.
public class ConseilFetchSentTransaction: RPC<[[String: Any]]> {
  public init(account: String, apiKey: String) {
    let headers = [
      Header.contentTypeApplicationJSON,
      Header(field: "apiKey", value: apiKey)
    ]

    super.init(
      endpoint: endpoint,
      headers: headers,
      responseAdapterClass: JSONArrayResponseAdapter.Self,
      payload: payload
    )
  }
}
