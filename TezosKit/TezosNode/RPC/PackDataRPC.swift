// Copyright Keefer Taylor, 2020

import Foundation

/// An RPC which will pack data to a binary format.
public class PackDataRPC: RPC<String> {
  public init(
    payload: PackDataPayload
  ) {
    let endpoint = "/chains/main/blocks/head/helpers/scripts/pack_data"
    let payload = JSONUtils.jsonString(for: payload.dictionaryRepresentation)

    super.init(
      endpoint: endpoint,
      headers: [ Header.contentTypeApplicationJSON ],
      responseAdapterClass: PackDataResponseAdapter.self,
      payload: payload
    )
  }
}
