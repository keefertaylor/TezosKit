// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC that will retrieve the delegate of a given address.
 */
public class GetDelegateRPC: TezosRPC<String> {
  /**
   * @param address The address to retrieve info about.
   * @param completion A completion block to be called on success or failure.
   */
  public init(address: String, completion: @escaping (String?, Error?) -> Void) {
    let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/delegate"
    super.init(endpoint: endpoint,
               responseAdapterClass: StringResponseAdapter.self,
               completion: completion)
  }
}
