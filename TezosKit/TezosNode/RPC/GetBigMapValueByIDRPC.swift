// Copyright Keefer Taylor, 2019

import BigInt
import Foundation

/// An RPC that will retrieve the value of a big map for the given key.
public class GetBigMapValueByIDRPC: RPC<[String: Any]> {
  /// - Parameters:
  ///   - address: The address of a smart contract with a big map.
  ///   - key: The key in the big map to look up.
  ///   - type: The michelson type of the key.
  public init(bigMapID: BigInt, expression: String) {
    let endpoint = "chains/main/blocks/head/context/big_maps/" + String(bigMapID) + "/" + expression

    super.init(
      endpoint: endpoint,
      responseAdapterClass: JSONDictionaryResponseAdapter.self
    )
  }
}
