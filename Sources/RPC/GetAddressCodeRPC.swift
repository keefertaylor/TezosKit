// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC which will retrieve the code associated with a smart contract.
 */
public class GetAddressCodeRPC: TezosRPC<[String: Any]> {
  /**
   * @param address The address of the contract to load.
   * @param completion A completion block to be called on success or failure.
   */
  public init(address: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
    let endpoint = "chains/main/blocks/head/context/contracts/\(address)/script"
    super.init(endpoint: endpoint,
               responseAdapterClass: JSONDictionaryResponseAdapter.self,
               completion: completion)
  }
}
