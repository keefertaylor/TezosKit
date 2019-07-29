// Copyright Keefer Taylor, 2019

import Foundation

private enum GetBigMapValueJSONConstants {
  public static let key = "key"
  public static let prim = "prim"
  public static let type = "type"
}

/// An RPC that will retrieve the value of a big map for the given key.
public class GetBigMapValueRPC: RPC<[String: Any]> {
  /// - Parameters:
  ///   - address: The address of a smart contract with a big map.
  ///   - key: The key in the big map to look up.
  ///   - type: The michelson type of the key.
  public init(address: Address, key: MichelsonParameter, type: MichelsonComparable) {
    let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/big_map_get"

    let payload = JSONUtils.jsonString(
      for: [
        GetBigMapValueJSONConstants.key: key.networkRepresentation,
        GetBigMapValueJSONConstants.type: GetBigMapValueRPC.typeDict(for: type)
      ]
    )

    let headers = Header(field: "content-type", value: "application/json")

    super.init(endpoint: endpoint, responseAdapterClass: JSONDictionaryResponseAdapter.self, payload: payload)
  }

  private static func typeDict(for type: MichelsonComparable) -> [String: String] {
    return [ GetBigMapValueJSONConstants.prim: type.rawValue ]
  }
}
