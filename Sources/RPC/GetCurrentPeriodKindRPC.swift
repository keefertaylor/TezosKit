// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC which will retrieve the current period kind for voting.
 *
 * TODO: This class should adapt to period kind, not a string.
 */
public class GetCurrentPeriodKindRPC: TezosRPC<String> {
  /**
   * @param completion A block to be called at the completion of the operation.
   */
  public init(completion: @escaping (String?, Error?) -> Void) {
    let endpoint = "chains/main/blocks/head/votes/current_period_kind"
    super.init(endpoint: endpoint,
               responseAdapterClass: StringResponseAdapter.self,
               completion: completion)
  }
}
