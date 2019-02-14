// Copyright Keefer Taylor, 2019

import Foundation

/** An RPC to make a request to the Conseil service. */
public class ConseilRequest: TezosRPC<String> {
  /**
   * - Parameter network: The network to query. Defaults to mainnet.
   * - Parameter entity: The entity to query.
   * - Parameter fields: The fields to request
   * - Parameter completion: A completion block to be called on success or failure.
   */
  // TODO: Conseil has a rich query language. Support it.
  public init(
    network: ConseilNetwork,
    entity: ConseilEntity,
    fields: [ConseilFields],
    completion: @escaping (String?, Error?) -> Void
  ) {
    let endpoint = "v2/data/tezos/" + network.rawValue + "/" + entity.rawValue

    let payload = ["fields": fields]
    let rawPayload = JSONUtils.jsonString(for: payload)

    // TODO: Just deserialize to a string for now. In the future, we can deserialize using a JSON adapter or
    //       create an object with the requested fields.
    super.init(
      endpoint: endpoint,
      responseAdapterClass: StringResponseAdapter.self,
      payload: rawPayload,
      completion: completion
    )
  }
}
