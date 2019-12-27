// Copyright Keefer Taylor, 2019.

import Foundation

/// An RPC that will retrieve the storage of a given contract.
public class GetContractStorageRPC: RPC<[String: Any]> {
  /// - Parameter address: The address to retrieve info about.
  public init(address: Address) {
    let endpoint = "/chains/main/blocks/head/context/contracts/\(address)/storage"
    super.init(endpoint: endpoint, responseAdapterClass: JSONDictionaryResponseAdapter.self)
  }
}
