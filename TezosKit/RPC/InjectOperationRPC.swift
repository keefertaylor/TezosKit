// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC which will inject an operation on the Tezos blockchain.
 */
public class InjectionRPC: TezosRPC<String> {
  /**
   * @param payload A JSON encoded string that represents the signed payload to inject.
   * @param completion A block to be called on completion of the operation.
   */
  public init(payload: String,
              completion: @escaping (String?, Error?) -> Void) {
    let endpoint = "/injection/operation"
    super.init(endpoint: endpoint,
               responseAdapterClass: StringResponseAdapter.self,
               payload: payload,
               completion: completion)
  }
}
