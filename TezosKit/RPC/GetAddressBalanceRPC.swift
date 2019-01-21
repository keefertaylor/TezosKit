// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC that will retrieve the balance of a given address.
 */
public class GetAddressBalanceRPC: TezosRPC<TezosBalance> {
  /**
   * @param address The address to retrieve info about.
   * @param completion A completion block to be called on success or failure.
   */
  public init(address: String, completion: @escaping (TezosBalance?, Error?) -> Void) {
    let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/balance"
    super.init(endpoint: endpoint,
               responseAdapterClass: TezosBalanceResponseAdapter.self,
               completion: completion)
  }
}
