// Copyright Keefer Taylor, 2018

import Foundation

/// An RPC which will retrieve ballots cast so far during a voting period.
public class GetBallotsListRPC: RPC<[[String: Any]]> {
  public init() {
    let endpoint = "/chains/main/blocks/head/votes/ballot_list"
    super.init(endpoint: endpoint, responseAdapterClass: JSONArrayResponseAdapter.self)
  }
}
