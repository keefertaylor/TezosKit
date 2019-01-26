// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC that will retrieve the manager key of a given address.
 */
public class GetAddressManagerKeyRPC: TezosRPC<[String: Any]> {
  /**
   * @param address The address to retrieve info about.
   * @param completion A completion block to be called on success or failure.
   */
  public init(address: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
    let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/manager_key"
    super.init(endpoint: endpoint,
               responseAdapterClass: JSONDictionaryResponseAdapter.self,
               completion: completion)
  }
}
