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
        GetBigMapValueJSONConstants.type: MichelsonComparable.networkRepresentation(for: type)
      ]
    )

    // The TezosNodeClient returns a HTTP 415 error if this header is not included with the payload. This behavior is
    // unique to this RPC. Adding this header to other RPCs causes them to fail with HTTP 415. ¯\_(ツ)_/¯
    let headers = [
      Header.contentTypeApplicationJSON
    ]

    super.init(
      endpoint: endpoint,
      headers: headers,
      responseAdapterClass: JSONDictionaryResponseAdapter.self,
      payload: payload
    )
  }
}
