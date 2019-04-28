// Copyright Keefer Taylor, 2018

import Foundation

/// An RPC which will retrieve a list of proposals with number of supporters.
public class GetProposalsListRPC: RPC<[[String: Any]]> {
  public init() {
    let endpoint = "chains/main/blocks/head/votes/proposals"
    super.init(endpoint: endpoint, responseAdapterClass: JSONArrayResponseAdapter.self)
  }
}
