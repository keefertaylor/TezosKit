// Copyright Keefer Taylor, 2018

import Foundation

/// An RPC that will retrieve the delegate of a given address.
public class GetDelegateRPC: RPC<String> {
  /// - Parameter address: The address to retrieve info about.
  public init(address: Address) {
    let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/delegate"
    super.init(endpoint: endpoint, responseAdapterClass: StringResponseAdapter.self)
  }
}
