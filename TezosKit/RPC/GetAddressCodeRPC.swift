// Copyright Keefer Taylor, 2018

import Foundation

/// An RPC which will retrieve the code associated with a smart contract.
public class GetAddressCodeRPC: RPC<ContractCode> {
  /// - Parameter address: The address of the contract to load.
  public init(address: String) {
    let endpoint = "chains/main/blocks/head/context/contracts/\(address)/script"
    super.init(endpoint: endpoint, responseAdapterClass: ContractCodeResponseAdapter.self)
  }
}
