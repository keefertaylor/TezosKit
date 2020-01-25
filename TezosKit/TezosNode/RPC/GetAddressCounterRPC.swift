// Copyright Keefer Taylor, 2018

import Foundation

/// A RPC which will retrieve the counter for an address.
public class GetAddressCounterRPC: RPC<Int> {
  /// - Parameter address: The address to retrieve info about.
  public init(address: Address) {
    let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/counter"
    super.init(endpoint: endpoint, responseAdapterClass: IntegerResponseAdapter.self)
  }
}
