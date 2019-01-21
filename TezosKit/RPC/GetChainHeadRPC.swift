// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC which will retrieve a JSON dictionary of info about the head of the current chain.
 */
public class GetChainHeadRPC: TezosRPC<[String: Any]> {
  /**
   * @param completion A block to be called at the completion of the operation.
   */
  public init(completion: @escaping ([String: Any]?, Error?) -> Void) {
    let endpoint = "chains/main/blocks/head"
    super.init(endpoint: endpoint,
               responseAdapterClass: JSONDictionaryResponseAdapter.self,
               completion: completion)
  }
}
