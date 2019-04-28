// Copyright Keefer Taylor, 2018

import Foundation

/// An RPC which will retrieve the current period kind for voting.
public class GetCurrentPeriodKindRPC: RPC<PeriodKind> {
  public init() {
    let endpoint = "chains/main/blocks/head/votes/current_period_kind"
    super.init(endpoint: endpoint, responseAdapterClass: PeriodKindResponseAdapter.self)
  }
}
