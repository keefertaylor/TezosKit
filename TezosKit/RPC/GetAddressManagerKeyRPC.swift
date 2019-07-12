// Copyright Keefer Taylor, 2018

import Foundation

/// An RPC that will retrieve the manager key of a given address.
public class GetAddressManagerKeyRPC: RPC<[String: Any]> {
  /// - Parameter address: The address to retrieve info about.
  public init(address: Address) {
    let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/manager_key"
    super.init(endpoint: endpoint, responseAdapterClass: JSONDictionaryResponseAdapter.self)
  }
}
