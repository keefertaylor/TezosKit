// Copyright Keefer Taylor, 2018

import Foundation

/// An RPC that will retrieve the balance of a given address.
public class GetAddressBalanceRPC: RPC<Tez> {
  /// - Parameter address: The address to retrieve info about.
  public init(address: Address) {
    let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/balance"
    super.init(endpoint: endpoint, responseAdapterClass: TezResponseAdapter.self)
  }
}
