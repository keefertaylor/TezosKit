// Copyright Keefer Taylor, 2018

import Foundation

/// An RPC which will inject an operation on the Tezos blockchain.
public class InjectionRPC: RPC<String> {
  /// - Parameter payload: A JSON encoded string that represents the signed payload to inject.
  public init(
    payload: String
  ) {
    let endpoint = "/injection/operation"
    super.init(
      endpoint: endpoint,
      headers: [Header.contentTypeApplicationJSON],
      responseAdapterClass: StringResponseAdapter.self,
      payload: payload
    )
  }
}
