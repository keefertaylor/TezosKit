// Copyright Keefer Taylor, 2019

import Foundation

/// Generic RPC to query Conseil.
public class ConseilQueryRPC<T>: RPC<T> {
  /// - Parameters:
  ///   - query: A query to send to Conseil
  ///   - path: The path to query.
  ///   - apiKey: The API key to send in the request headers.
  ///   - platform: The platform to query.
  ///   - network: The network to query.
  ///   - responseAdapterClass: The class of the response adapter which will take bytes received from the request and
  ///     transform them into a specific type.
  public init?(
    query: [String: Any],
    path: String,
    apiKey: String,
    platform: ConseilPlatform,
    network: ConseilNetwork,
    responseAdapterClass: AbstractResponseAdapter<T>.Type
  ) {
    guard let escapedPlatform = platform.rawValue.addingPercentEncoding(
      withAllowedCharacters: CharacterSet.urlQueryAllowed
      ),
      let escapedNetwork = network.rawValue.addingPercentEncoding(
        withAllowedCharacters: CharacterSet.urlQueryAllowed
      ) else {
        return nil
    }
    let endpoint = "/v2/data/\(escapedPlatform)/\(escapedNetwork)/\(path)"
    let headers = [
      Header.contentTypeApplicationJSON,
      Header(field: "apiKey", value: apiKey)
    ]

    super.init(
      endpoint: endpoint,
      headers: headers,
      responseAdapterClass: responseAdapterClass,
      payload: JSONUtils.jsonString(for: query)
    )
  }
}
