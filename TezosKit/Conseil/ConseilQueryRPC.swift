// Copyright Keefer Taylor, 2019

import Foundation

/// Generic RPC to query Conseil.
public class ConseilQueryRPC<T>: RPC<T> {
  /// - Parameters:
  ///   - query: A query to send to Conseil
  ///   - entity: The entity to query.
  ///   - responseAdapterClass: The class of the response adapter which will take bytes received from the request and
  ///     transform them into a specific type.
  public init(
    query: [String: Any],
    entity: ConseilEntity,
    responseAdapterClass: AbstractResponseAdapter<T>.Type
  ) {
    let endpoint = "\(entity.rawValue)"
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
