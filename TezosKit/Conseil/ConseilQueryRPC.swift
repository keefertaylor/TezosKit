// Copyright Keefer Taylor, 2019

import Foundation

/// Generic RPC to query Conseil.
public class ConseilQueryRPC<T>: RPC<T> {
  /// - Parameters:
  ///   - query: A query to send to Conseil
  ///   - path: The path to query.
  ///   - responseAdapterClass: The class of the response adapter which will take bytes received from the request and
  ///     transform them into a specific type.
  public init(
    query: [String: Any],
    path: String,
    responseAdapterClass: AbstractResponseAdapter<T>.Type
  ) {
    let endpoint = "/\(path)"
    let headers = [
      Header.contentTypeApplicationJSON
    ]

    super.init(
      endpoint: endpoint,
      headers: headers,
      responseAdapterClass: responseAdapterClass,
      payload: JSONUtils.jsonString(for: query)
    )
  }
}
