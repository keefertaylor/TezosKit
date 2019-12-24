// Copyright Keefer Taylor, 2018

import Foundation

/// An RPC which will retrieve a list of delegates with their voting weight, in number of rolls.
public class GetVotingDelegateRightsRPC: RPC<[[String: Any]]> {
  public init() {
    let endpoint = "chains/main/blocks/head/votes/listings"
    super.init(endpoint: endpoint, responseAdapterClass: JSONArrayResponseAdapter.self)
  }
}
