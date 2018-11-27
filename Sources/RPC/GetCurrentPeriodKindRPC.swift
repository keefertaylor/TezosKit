// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC which will retrieve the current period kind for voting.
 */
public class GetCurrentPeriodKindRPC: TezosRPC<PeriodKind> {
  /**
   * @param completion A block to be called at the completion of the operation.
   */
  public init(completion: @escaping (PeriodKind?, Error?) -> Void) {
    let endpoint = "chains/main/blocks/head/votes/current_period_kind"
    super.init(endpoint: endpoint,
               responseAdapterClass: PeriodKindResponseAdapter.self,
               completion: completion)
  }
}
