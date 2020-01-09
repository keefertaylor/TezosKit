// Copyright Keefer Taylor, 2020

import Foundation

/// An RPC which will pack data to a binary format.
public class PackDataRPC: RPC<String> {
  public init(
    input: [String: Any]
  ) {
    let endpoint = "/chains/main/blocks/head/helpers/scripts/pack_data"
    let payload = JSONUtils.jsonString(for: input)

    super.init(
      endpoint: endpoint,
      headers: [ Header.contentTypeApplicationJSON ],
      responseAdapterClass: StringResponseAdapter.self,
      payload: payload
    )
  }
}
